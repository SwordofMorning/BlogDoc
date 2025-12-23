# build.py
import PyInstaller.__main__
import os
import shutil

def build():
    print("使用 Spec 文件开始构建...")

    # 1. clean原有构建文件
    if os.path.exists('dist'):
        shutil.rmtree('dist')
    if os.path.exists('build'):
        shutil.rmtree('build')

    # 2. 选择配置文件 build_config.spec
    params = [
        'build_config.spec',
        # 构建前清理文件
        '--clean'
    ]

    # 3. (Make) 调用pyinstaller执行构建
    PyInstaller.__main__.run(params)
    
    print("构建完成！")

if __name__ == "__main__":
    build()