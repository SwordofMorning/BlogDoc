# demo_app.spec
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['main.py'],             # 源代码列表
    pathex=[],               # 额外的搜索路径
    binaries=[],             # 需要包含的二进制文件 (如 .dll, .so)
    datas=[],                # 非代码资源文件 (如图片, 配置文件)
    hiddenimports=[],        # PyInstaller 无法自动检测到的隐式导入库
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],             # 不需要打包的库
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='demo_app',          # 输出的可执行文件名
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,                 # 是否使用 UPX 压缩
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,             # True=显示控制台(命令行程序), False=隐藏(GUI程序)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)