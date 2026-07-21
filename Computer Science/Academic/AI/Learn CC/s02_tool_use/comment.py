#!/usr/bin/env python3
"""
s02: Tool Use — 在 s01 基础上新增 4 个工具 + 分发映射。
新增特性: 自定义 fprint，将详细的 Trace 调试日志输出至 agent_trace.log 文件，保持终端简洁。

运行: python s02_tool_use/code.py
需要: pip install anthropic python-dotenv + .env 中配置 ANTHROPIC_API_KEY
"""

import json
import os
from pathlib import Path
import re
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

WORKDIR = Path.cwd()
LOG_FILE = WORKDIR / "agent_trace.log"

client = Anthropic(base_url=os.getenv("ANTHROPIC_BASE_URL"))
MODEL = os.environ["MODEL_ID"]

SYSTEM = f"You are a coding agent at {WORKDIR}. Use tools to solve tasks. Act, don't explain."


# ═══════════════════════════════════════════════════════════
#  日志输出核心：fprint 实现
# ═══════════════════════════════════════════════════════════


def fprint(*args, sep=" ", end="\n", to_stdout=False):
    """自定义日志输出函数：

    - 默认将内容追加写入 agent_trace.log（自动剔除 ANSI 颜色控制码）。
    - 若指定 to_stdout=True，则同步在控制台终端显示（保留颜色）。
    """
    msg = sep.join(map(str, args)) + end

    # 1. 写入日志文件（正则过滤掉 \033[...m ANSI 转义颜色码，保证 .log 文件纯净可读）
    clean_msg = re.sub(r"\033\[[0-9;]*m", "", msg)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(clean_msg)

    # 2. 如果需要同步刷到终端，则保留颜色输出
    if to_stdout:
        print(msg, end="")


# ═══════════════════════════════════════════════════════════
#  5 个工具的具体实现
# ═══════════════════════════════════════════════════════════


def run_bash(command: str) -> str:
    dangerous = ["rm -rf /", "sudo", "shutdown", "reboot", "> /dev/"]
    if any(d in command for d in dangerous):
        return "Error: Dangerous command blocked"
    try:
        r = subprocess.run(
            command,
            shell=True,
            cwd=WORKDIR,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=120,
        )
        out = (r.stdout + r.stderr).strip()
        return out[:50000] if out else "(no output)"
    except subprocess.TimeoutExpired:
        return "Error: Timeout (120s)"
    except (FileNotFoundError, OSError) as e:
        return f"Error: {e}"


# 针对Python代码的“路径保护”，但是不能对`../../..`一类的路径进行保护
def safe_path(p: str) -> Path:
    path = (WORKDIR / p).resolve()
    if not path.is_relative_to(WORKDIR):
        raise ValueError(f"Path escapes workspace: {p}")
    return path


def run_read(path: str, limit: int | None = None) -> str:
    try:
        lines = safe_path(path).read_text().splitlines()
        if limit and limit < len(lines):
            lines = lines[:limit] + [f"... ({len(lines) - limit} more lines)"]
        return "\n".join(lines)
    except Exception as e:
        return f"Error: {e}"


def run_write(path: str, content: str) -> str:
    try:
        file_path = safe_path(path)
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content)
        return f"Wrote {len(content)} bytes to {path}"
    except Exception as e:
        return f"Error: {e}"


def run_edit(path: str, old_text: str, new_text: str) -> str:
    try:
        file_path = safe_path(path)
        text = file_path.read_text()
        if old_text not in text:
            return f"Error: text not found in {path}"
        file_path.write_text(text.replace(old_text, new_text, 1))
        return f"Edited {path}"
    except Exception as e:
        return f"Error: {e}"


# 搜索工具，提供给LLM进行文件查找
def run_glob(pattern: str) -> str:
    import glob as g
    try:
        results = []
        for match in g.glob(pattern, root_dir=WORKDIR):
            if (WORKDIR / match).resolve().is_relative_to(WORKDIR):
                results.append(match)
        return "\n".join(results) if results else "(no matches)"
    except Exception as e:
        return f"Error: {e}"


# ═══════════════════════════════════════════════════════════
#  工具 Schema 定义与分发映射表
# ═══════════════════════════════════════════════════════════

TOOLS = [
    {
        "name": "bash",
        "description": "Run a shell command.",
        "input_schema": {
            "type": "object",
            "properties": {"command": {"type": "string"}},
            "required": ["command"],
        },
    },
    {
        "name": "read_file",
        "description": "Read file contents.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "limit": {"type": "integer"},
            },
            "required": ["path"],
        },
    },
    {
        "name": "write_file",
        "description": "Write content to a file.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "content": {"type": "string"},
            },
            "required": ["path", "content"],
        },
    },
    {
        "name": "edit_file",
        "description": "Replace exact text in a file once.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "old_text": {"type": "string"},
                "new_text": {"type": "string"},
            },
            "required": ["path", "old_text", "new_text"],
        },
    },
    {
        "name": "glob",
        "description": "Find files matching a glob pattern.",
        "input_schema": {
            "type": "object",
            "properties": {"pattern": {"type": "string"}},
            "required": ["pattern"],
        },
    },
]

TOOL_HANDLERS = {
    "bash": run_bash,
    "read_file": run_read,
    "write_file": run_write,
    "edit_file": run_edit,
    "glob": run_glob,
}


# ═══════════════════════════════════════════════════════════
#  agent_loop — 全量 Trace 日志打入 fprint，终端保持轻量提示
# ═══════════════════════════════════════════════════════════


def agent_loop(messages: list):
    loop_step = 1
    while True:
        fprint(
            f"\n\033[1;34m==================== [ Agent Loop 轮次 #{loop_step} ] ====================\033[0m"
        )

        # ── 1. 记录完整的 Payload 历史到日志文件 ────────────────────────
        fprint("\033[35m[2. 发送给模型的 Messages Payload 历史记录]:\033[0m")
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

        fprint(
            json.dumps(
                debug_messages, indent=2, ensure_ascii=False, default=str
            )
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

        # ── 2. 记录模型返回元数据与 Block 解析 ─────────────────────────
        fprint("\n\033[36m[3. 模型返回的原始 Response 元数据]:\033[0m")
        fprint(f"  ├─ stop_reason: \033[1;32m{response.stop_reason}\033[0m")
        fprint(f"  └─ content 包含 {len(response.content)} 个 Block:")

        for idx, block in enumerate(response.content):
            block_type = getattr(block, "type", None)
            fprint(f"     ├─ Block[{idx}] 类型: \033[1m{block_type}\033[0m")
            if block_type == "tool_use":
                fprint(f"     │  ├─ 工具名称: \033[1;33m{block.name}\033[0m")
                fprint(
                    f"     │  └─ 工具参数: \033[33m{json.dumps(block.input, ensure_ascii=False)}\033[0m"
                )
            elif block_type == "text":
                fprint(f"     │  └─ 文本回答: {block.text}")
                # 将模型的文本回答输出到控制台终端，使用户能看到对话进展
                print(f"\n\033[32mAgent:\033[0m {block.text}")

        # ── 3. 判定与多工具分发执行 ────────────────────────────────────
        fprint("\n\033[32m[4. 程序逻辑判定与工具执行]:\033[0m")

        if response.stop_reason != "tool_use":
            fprint(
                f"  └─ 判定：stop_reason 为 '{response.stop_reason}'，任务结束。\n"
            )
            return

        fprint(
            "  └─ 判定：stop_reason == 'tool_use'！程序开始提取工具请求并分发执行..."
        )

        results = []
        for block in response.content:
            if block.type == "tool_use":
                tool_name = block.name
                tool_args = block.input
                handler = TOOL_HANDLERS.get(tool_name)

                # 在终端显示轻量的工具执行提示，让用户知道后台正在干活
                print(
                    f"\033[33m > 正在调用工具 [{tool_name}]...\033[0m",
                    flush=True,
                )

                fprint(
                    f"\n\033[33m     [调用工具 {tool_name}]: 参数 = {json.dumps(tool_args, ensure_ascii=False)}\033[0m"
                )

                if handler:
                    output = handler(**tool_args)
                else:
                    output = f"Error: Unknown tool '{tool_name}'"

                # 记录前 200 字符预览至日志
                preview = str(output)[:200].replace("\n", " ")
                fprint(f"     [工具返回结果]: {preview}...")

                results.append(
                    {
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": output,
                    }
                )

        # 挂载结果回消息队列，进入下一轮循环
        messages.append({"role": "user", "content": results})
        loop_step += 1


if __name__ == "__main__":
    # 初始化清空旧的日志文件
    LOG_FILE.write_text("", encoding="utf-8")

    print("s02: Tool Use — 已开启文件 Trace 调试日志")
    print(f"所有详细日志已自动保存至: {LOG_FILE.resolve()}")
    print("你可以另开一个终端执行 `tail -f agent_trace.log` 实时查看 Trace。\n")

    history = []
    while True:
        try:
            query = input("\033[36ms02 >> \033[0m")
        except (EOFError, KeyboardInterrupt):
            break
        if query.strip().lower() in ("q", "exit", ""):
            break

        fprint(f"\n\n==================== [ 用户新对话 ] ====================")
        fprint(f"User Query: {query}")

        history.append({"role": "user", "content": query})
        agent_loop(history)