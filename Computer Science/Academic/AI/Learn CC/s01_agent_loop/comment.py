#!/usr/bin/env python3
"""
s01_agent_loop.py - The Agent Loop

The entire secret of an AI coding agent in one pattern:

    while stop_reason == "tool_use":
        response = LLM(messages, tools)
        execute tools
        append results

    +----------+      +-------+      +---------+
    |   User   | ---> |  LLM  | ---> |  Tool   |
    |  prompt  |      |       |      | execute |
    +----------+      +---+---+      +----+----+
                          ^               |
                          |   tool_result |
                          +---------------+
                          (loop continues)

This is the core loop: feed tool results back to the model
until the model decides to stop. Production agents layer
policy, hooks, and lifecycle controls on top.

Usage:
    pip install anthropic python-dotenv
    ANTHROPIC_API_KEY=... python s01_agent_loop/code.py
"""

import json
import os
import subprocess

try:
    import readline

    readline.parse_and_bind("set bind-tty-special-chars off")
    readline.parse_and_bind("set input-meta on")
    readline.parse_and_bind("set output-meta on")
    readline.parse_and_bind("set convert-meta off")
except ImportError:
    pass

from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv(override=True)

if os.getenv("ANTHROPIC_BASE_URL"):
    os.environ.pop("ANTHROPIC_AUTH_TOKEN", None)

client = Anthropic(base_url=os.getenv("ANTHROPIC_BASE_URL"))
MODEL = os.environ["MODEL_ID"]

SYSTEM = f"You are a coding agent at {os.getcwd()}. Use bash to solve tasks. Act, don't explain."

TOOLS = [{
    "name": "bash",
    "description": "Run a shell command.",
    "input_schema": {
        "type": "object",
        "properties": {"command": {"type": "string"}},
        "required": ["command"],
    },
}]


def run_bash(command: str) -> str:
    dangerous = ["rm -rf /", "sudo", "shutdown", "reboot", "> /dev/"]
    if any(d in command for d in dangerous):
        return "Error: Dangerous command blocked"
    try:
        r = subprocess.run(
            command,
            shell=True,
            cwd=os.getcwd(),
            capture_output=True,
            text=True,
            timeout=120,
        )
        out = (r.stdout + r.stderr).strip()
        return out[:50000] if out else "(no output)"
    except subprocess.TimeoutExpired:
        return "Error: Timeout (120s)"
    except (FileNotFoundError, OSError) as e:
        return f"Error: {e}"


def agent_loop(messages: list):
    loop_step = 1
    while True:
        print(
            f"\n\033[1;34m==================== [ Agent Loop 轮次 #{loop_step} ] ====================\033[0m"
        )

        # ── 打印点 2：程序向模型发送的完整 Prompt/Messages ─────────────
        print("\033[35m[2. 发送给模型的 Messages Payload 历史记录]:\033[0m")
        # 转换对象格式以便美化打印 JSON
        debug_messages = []
        for m in messages:
            content = m["content"]
            if isinstance(content, list):
                rendered_blocks = []
                for b in content:
                    if hasattr(b, "model_dump"):
                        rendered_blocks.append(b.model_dump())
                    else:
                        rendered_blocks.append(b)
                debug_messages.append(
                    {"role": m["role"], "content": rendered_blocks}
                )
            else:
                debug_messages.append(m)

        print(
            json.dumps(debug_messages, indent=2, ensure_ascii=False, default=str)
        )

        # 请求 LLM
        response = client.messages.create(
            model=MODEL,
            system=SYSTEM,
            messages=messages,
            tools=TOOLS,
            max_tokens=8000,
        )

        # 追加助手轮次
        messages.append({"role": "assistant", "content": response.content})

        # ── 打印点 3：模型返回的原始 Response 内容 ────────────────────
        print("\n\033[36m[3. 模型返回的原始 Response 元数据]:\033[0m")
        print(f"  ├─ stop_reason: \033[1;32m{response.stop_reason}\033[0m")
        print(f"  └─ content 包含 {len(response.content)} 个 Block:")

        for idx, block in enumerate(response.content):
            block_type = getattr(block, "type", None)
            print(f"     ├─ Block[{idx}] 类型: \033[1m{block_type}\033[0m")
            if block_type == "tool_use":
                print(f"     │  ├─ 工具名称: {block.name}")
                print(f"     │  └─ 工具参数 (Command): \033[33m{block.input['command']}\033[0m")
            elif block_type == "text":
                print(f"     │  └─ 文本回答: {block.text}")

        # ── 打印点 4：程序如何判断模型返回的是否为可执行语句 ─────────────
        print("\n\033[32m[4. 程序逻辑判定与工具执行]:\033[0m")

        # 判断核心：stop_reason 是否为 "tool_use"
        if response.stop_reason != "tool_use":
            print(
                f"  └─ 判定：stop_reason 为 '{response.stop_reason}'，表示模型不再需要调用工具，任务结束。\n"
            )
            return

        print(
            "  └─ 判定：stop_reason == 'tool_use'！程序开始提取 Bash 命令并调用系统 Shell 执行..."
        )

        results = []
        for block in response.content:
            if block.type == "tool_use":
                cmd = block.input["command"]
                print(f"\n\033[33m     [执行 Bash 命令]: $ {cmd}\033[0m")
                output = run_bash(cmd)
                print(f"     [标准终端输出]: {output[:200]}")
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": output,
                })

        # 将工具执行结果装入消息队列，继续下一个循环（Loop Continues）
        messages.append({"role": "user", "content": results})
        loop_step += 1


if __name__ == "__main__":
    print("s01: Agent Loop (增强诊断版)")
    print("输入问题，回车发送。输入 q 退出。\n")

    history = []
    while True:
        try:
            query = input("\033[36ms01 >> \033[0m")
        except (EOFError, KeyboardInterrupt):
            break
        if query.strip().lower() in ("q", "exit", ""):
            break

        # ── 打印点 1：捕获你输入的原始 Text ─────────────────────────────
        print(f"\n\033[35m[1. 用户输入原始 Text]: {query}\033[0m")

        history.append({"role": "user", "content": query})
        agent_loop(history)

        # 最终文本输出
        response_content = history[-1]["content"]
        if isinstance(response_content, list):
            for block in response_content:
                if getattr(block, "type", None) == "text":
                    print(f"\033[32m[Agent 最终回答]: {block.text}\033[0m")
        print()