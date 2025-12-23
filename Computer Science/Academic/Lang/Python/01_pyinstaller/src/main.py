# main.py

# 标准库
import argparse
import sys
# 第三方库
from colorama import init, Fore, Style

# 初始化 colorama
init()

def main():
    # 1. 创建 ArgumentParser 对象
    parser = argparse.ArgumentParser(description="一个用于演示 PyInstaller 打包的示例程序")

    # 2. 添加参数 --print
    parser.add_argument('--print', type=str, help='需要打印的字符串内容')

    # 3. 解析参数
    args = parser.parse_args()

    # 4. 业务逻辑
    if args.print:
        # 使用第三方库 colorama 输出绿色文字
        print(f"{Fore.GREEN}[INFO] 接收到的参数内容: {Style.RESET_ALL} {args.print}")
    else:
        print(f"{Fore.RED}[ERROR] 未提供 --print 参数。{Style.RESET_ALL}")
        print(f"用法示例: {sys.argv[0]} --print \"Hello World\"")

if __name__ == "__main__":
    main()