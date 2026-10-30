# device: 烧录分区表与挂载对照

本文件描述 HiSilicon Hi3556V200 产品的 EMMC 分区布局、运行时挂载逻辑、
构建产物对应关系，以及修改分区的方法。

## 1. EMMC 分区总表

分区定义有两处来源，必须保持一致：

- `device/usb-burn.xml`：烧录工具 (smartburn) 使用
- `release/env.txt` 中 bootargs 的 `blkdevparts`：u-boot 使用

| 分区号 | 名称 | 起始 | 大小 | 内容 | 挂载点 | 使用方 |
|--------|------|------|------|------|--------|--------|
| p1 | boot (fastboot) | 0 | 512K | u-boot 二进制 | 不挂载 | u-boot 自举 |
| p2 | env | 512K | 512K | u-boot 环境变量 (bootargs/bootcmd) | 不挂载 | u-boot |
| p3 | logo | 1M | 1M | 开机图 JPEG 1024x768 | 不挂载 | u-boot (decjpg/startvo) |
| p4 | kernel | 2M | 5M | uImage (Linux-4.19.90) | 不挂载 | u-boot (bootm) |
| p5 | rootfs | 7M | 64M | ext4 系统 (busybox/库/init) | `/` | kernel + init |
| p6 | app | 71M | 64M | ext4 产品程序 (mickey_smart 等) | `/root` | init (S05mount) |
| p7 | resource | 135M | 64M | ext4 配置/UI (net/cfg/ui) | `/opt/resource` | init (S05mount) |
| p8 | reserved1 | 199M | 64M | 预留 | - | - |
| p9 | reserved2 | 263M | 64M | 预留 | - | - |
| p10 | reserved3 | 327M | 1M | 预留 | - | - |
| p11 | user | 328M | 剩余 | vfat 数据 (自动格式化) | `/mnt` | init (S05mount) |

对应 blkdevparts 原文：
`blkdevparts=mmcblk0:512K(boot),512K(env),1M(logo),5M(kernel),64M(rootfs),64M(app),64M(resource),64M(reserved1),64M(reserved2),1M(reserved3),-(user)`

## 2. 运行时挂载逻辑 (fs_overlay/etc/init.d/)

启动链：kernel → busybox init → `/etc/inittab` (::sysinit) → `/etc/init.d/rcS`
→ rcS 按字典序执行 S[0-9][0-9]*：

| 脚本 | 作用 |
|------|------|
| S00devs | mknod console / ttyAMA0 / ttyAMA1 / ttyS000 / null |
| S01udev | 启动 haveged (熵源)，挂载 devpts 到 /dev/pts，启动 udevd |
| S05mount | 分区挂载 (见下) |
| S80network | 解析内核 cmdline 的 ip= 参数，配置网卡 |
| S90appStart | 执行 /root/scripts/run_app.sh (app 分区主程序) |

S05mount 具体动作：
- 最后一个 mmcblk0 分区 (p11 user)：非 vfat 则自动格式化为 vfat → 挂载 `/mnt`
- tmpfs → `/tmp`
- p6 (app) ext4 → `/root`
- p7 (resource) ext4 → `/opt/resource`
- 软链：`/etc/hostapd.conf` → `/opt/resource/net/hostapd.conf`、`/etc/udhcpd.conf` → `/opt/resource/net/udhcpd.conf`

fstab (S05mount 之外仅此三项)：proc → /proc，sysfs → /sys，tmpfs → /dev

要点：app 分区挂载到 `/root`，因此设备上的 `/root/scripts/run_app.sh`
就是 app 分区里的 `scripts/run_app.sh` (rootfs 的 /root 只是空挂载点)。

## 3. 构建产物 ↔ 分区 ↔ 设备路径对照

| 构建产物 (build/release/) | 分区 | 设备节点 | 挂载点 | 构建来源 (build/fs/) |
|---------------------------|------|----------|--------|----------------------|
| boot | p1 | /dev/mmcblk0p1 | - | u-boot 构建输出 |
| env | p2 | /dev/mmcblk0p2 | - | release/env.txt → mkenvimage |
| logo | p3 | /dev/mmcblk0p3 | - | fs_overlay/logo.jpg |
| kernel | p4 | /dev/mmcblk0p4 | - | uImage_hi3556v200_smp |
| rootfs | p5 | /dev/mmcblk0p5 | / | fs/rootfs (rootfs_glibc.tgz 合并后) |
| app | p6 | /dev/mmcblk0p6 | /root | fs/app (= osdrv/pub/app) |
| resource | p7 | /dev/mmcblk0p7 | /opt/resource | fs/resource (= fs_overlay/opt/resource) |

## 4. 与 VS839 (A/B 双分区) 设计的差异

| 维度 | VS839 (vs8x9) | 本产品 (hi3556v200) |
|------|---------------|---------------------|
| 系统分区 | A/B 双份 (dtb/kernel/rootfs) | 单份，无 A/B |
| 升级 | xOTA + misc 分区槽位切换 | autoup (uboot 阶段) + upgrade_tool (用户空间) |
| app 分区 | 256M，挂载 /app (应用自己管理) | 64M，挂载 /root (init 直接拉起) |
| vendor | 32M 独立分区 | 无 (产品配置在 resource 分区) |
| userdata | 独立分区 | user 分区挂 /mnt (vfat) |
| 根文件系统 | init=/linuxrc (busybox 直启) | inittab + rcS 脚本链 |

## 5. 修改分区的方法

1. 修改 `device/usb-burn.xml` 的 Start/Length (烧录工具)
2. 同步修改 `release/env.txt` 的 blkdevparts (u-boot)
3. 若分区大小变化，同步调整 `build.sh` 中 build_release 的三个 ext4 镜像大小参数 (64M)
4. 若新增/删除挂载，修改 `fs_overlay/etc/init.d/S05mount` (注意: 文件路径含 etc,
   在仓库中通过 fs_overlay 目录编辑)
5. 重新构建: `./build.sh rootfs && ./build.sh release`

注意: 设备节点号 (p1~p11) 由 blkdevparts 顺序自动分配，改分区表后节点号
会随之变化，S05mount 中的挂载关系 (p6→/root, p7→/opt/resource) 需同步核对。


## 6. OTA 升级机制

### 6.1 总览: 两个升级工具, 一个原则

原则: **uboot 负责刷写, 用户空间负责传文件**。

| 工具 | 形态 | 位置 | 源码 | 职责 |
|------|------|------|------|------|
| autoup | u-boot 内置命令 | 编译进 u-boot.bin | `open_source/u-boot/u-boot-2020.01/product/hiupdate/` (auto_update.c / auto_update_adaptation.c) | 开机阶段扫描介质上的分区文件, md5 校验后写分区 |
| upgrade_tool | ARM 二进制 (31KB) | app 分区 `program/upgrade_tool` | 无 (海思 SmartCam 预编译, 树内只有二进制) | 用户空间解析 smartcam_upgrade.bin 整包, 写 /dev/mmcblk0pX |

bootcmd 中的升级调用点 (release/env.txt):
`... startvl ...; init_sc; autoup; mmc read 0 0x82000000 0x1000 0x2800; bootm 0x82000000`
即: 每次开机显示开机图后都执行 autoup, 无升级文件则快速跳过。

autoup 扫描介质 (auto_update_adaptation.c 中 s_intf 数组):
- mmc (eMMC user 分区, vfat) — 手机 App 升级路径
- usb (U 盘) — 售后/工厂路径

升级文件命名约定 (位于介质根目录):
`boot env logo kernel rootfs app resource` + 同名 `md5*` 校验文件
(md5 比对通过才写入; 升级完成后由 `boot_upgrade_file_delete.sh` 清理)

### 6.2 场景一: 手机 App 在线升级 (日常 OTA)

升级包形态: `1.0.20_app.zip` (手机 App 升级包) — 仅含 **kernel / app / resource** 三个分区 + md5*, 刻意不含 boot/env/rootfs (应用层只能升级应用层能动的分区)。

1. 手机 App 连接设备 (wifi AP 模式 192.168.7.x, 或 STA 模式设备联网)
2. App 从云端下载升级包
3. App 通过设备暴露的通道把文件写入 user 分区 (/mnt):
   - 网络共享: `app/scripts/usb_tools/Config_Storage_Eth.sh` (rndis/eth)
   - FTP: vsftpd (local_root=/mnt, admin 账号, 配置在 resource 分区 net/vsftpd.conf)
   - USB 存储模式: `app/scripts/usb_tools/Config_Storage.sh`
4. 触发重启
5. 重启 → uboot 显示开机图 (decjpg/startvo/startvl) → init_sc → **autoup**
6. autoup 扫描 mmc user 分区 → 找到 kernel/app/resource + md5* → 校验 → 写对应分区 (p4/p6/p7)
7. bootm 启动内核 → 系统起来 → S05mount 挂载 /mnt → run_app.sh → boot_upgrade_file_delete.sh 清理
8. 新版本生效

### 6.3 场景二: U 盘升级 (售后/现场/返修)

- 准备: U 盘根目录放分区文件 (boot/env/logo/kernel/rootfs/app/resource + md5*), 或 smartcam_upgrade.bin 整包
- 方式 A (uboot 路径): 插 U 盘 → 重启 → autoup 扫描 USB → md5 校验 → 刷写 → 系统起来后自动清理
- 方式 B (用户空间路径): 设备运行中插 U 盘 → S05mount 挂载到 /mnt → 若发现 smartcam_upgrade.bin → run_app.sh 调 upgrade_tool 解析整包写分区 → 重启生效
  - upgrade_tool 用法: `upgrade_tool <smartcam_upgrade.bin> <product_name>`, product_name 取自 /opt/resource/cfg/config_devmng.ini 的 model

### 6.4 场景三: 工厂首次烧录

Windows 端 smartburn 工具 + `device/usb-burn.xml` 分区表, 将 `build/release/` 的 7 个文件逐分区烧写。

### 6.5 相关代码/文件索引

| 内容 | 位置 |
|------|------|
| autoup 实现 (uboot) | open_source/u-boot/u-boot-2020.01/product/hiupdate/ |
| 升级触发 (用户空间) | osdrv/pub/app/scripts/run_app.sh (smartcam_upgrade.bin 检测) |
| 升级文件清理 | osdrv/pub/app/scripts/boot_upgrade_file_delete.sh |
| upgrade_tool 二进制 | osdrv/pub/app/program/upgrade_tool (无源码) |
| 手机升级包样例 | 版本包: 手机APP升级包/1.0.20_app.zip |
| 文件传输通道 | osdrv/pub/app/scripts/usb_tools/, fs_overlay/opt/resource/net/vsftpd.conf |
| 分区表 | device/usb-burn.xml + release/env.txt (blkdevparts) |

### 6.6 与 VS839 (A/B + xOTA) 的差异

| 维度 | VS839 | Hi3556 本产品 |
|------|-------|---------------|
| 升级执行者 | xOTA (用户空间, 自研) | autoup (uboot 阶段, 海思) |
| 用户空间职责 | 直接写 raw EMMC | 只负责把文件放到 /mnt |
| 槽位 | A/B 双槽 + 回退 | 单分区, 无回退 |
| 校验 | (自研实现) | 仅 md5, 无签名 |
| 升级范围 | xOTA 全包 (dtb/kernel/rootfs) | 手机包仅 kernel/app/resource; U 盘可全 7 分区 |
| app 升级 | deb 包 + dpkg (应用组管理) | 整分区镜像 (app.ext4), autoup/upgrade_tool 整分区写 |

### 6.7 已知风险与改进方向

- 无 A/B 回退: 升级中途断电可能变砖 (理论), rootfs 升级失败需 USB 重刷
- 仅 md5 校验, 无签名: 存在被篡改升级包的风险
- 改进方向 (autoup 源码在手): 加签名校验 / A/B 槽位 / 升级日志记录, 架构无需变动
