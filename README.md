# 安装指南

---

## 目录结构

```
.
├── flake.nix                    ← 只有 inputs + imports，别的什么都没有
│
├── flake/                       ← flake-parts 模块（管理 flake 输出）
│   ├── overlays.nix             ← flake.overlays + perSystem nixpkgs 配置
│   ├── hosts.nix                ← flake.nixosConfigurations（在这里注册机器）
│   ├── devshell.nix             ← perSystem.devShells（nix develop 用的工具）
│   ├── formatter.nix            ← perSystem.formatter（nix fmt）
│   └── checks.nix               ← perSystem.checks（nix flake check）
│
├── hosts/
│   └── myhostname/
│       ├── default.nix          ← host 入口：imports NixOS 模块
│       └── hardware.nix         ← nixos-generate-config 生成
│
└── modules/
    ├── nixos/                   ← NixOS 模块（管理系统）
    │   ├── disk.nix             ← disko 分区方案
    │   ├── boot.nix             ← Limine + LUKS 解锁 + btrfs rollback
    │   ├── system.nix           ← 用户、时区、基础设置
    │   └── impermanence.nix     ← opt-in 持久化声明
    └── home/                    ← home-manager 模块（管理用户）
        ├── default.nix          ← 入口：home-manager 全局选项 + imports
        ├── packages.nix         ← 用户级软件包
        ├── shell.nix            ← shell 配置
        └── git.nix              ← git 配置
```

### 三层模块，职责完全分离

| 层 | 位置 | 问"我是谁" | 用途 |
|---|---|---|---|
| **flake-parts 模块** | `flake/*.nix` | 导出 `perSystem`、`flake` 属性 | 组织 flake 本身的输出 |
| **NixOS 模块** | `modules/nixos/*.nix`、`hosts/*` | 声明 `boot.*`、`services.*` 等选项 | 配置操作系统 |
| **home-manager 模块** | `modules/home/*.nix` | 声明 `programs.*`、`home.*` 等选项 | 配置用户环境 |

`flake/hosts.nix` 是连接点：它是 flake-parts 模块，调用 `nixosSystem` 并把 NixOS 模块和 home-manager 模块传进去。

---

## 安装步骤

### 第一步：联网

```bash
nmcli device wifi connect "SSID" password "密码"
```

### 第二步：克隆配置

```bash
nix-shell -p git
git clone https://github.com/yourname/nixos-config /tmp/cfg
cd /tmp/cfg
```

### 第三步：修改占位符

全部用 `⚠` 标注在代码里，一共要改：

| 文件 | 要改的内容 |
|---|---|
| `flake/hosts.nix` | `myhostname`（键名 + 路径） |
| `hosts/myhostname/default.nix` | `networking.hostName` |
| `modules/nixos/disk.nix` | `device`（磁盘路径，`lsblk` 查） |
| `modules/nixos/system.nix` | `yourname`、时区、密码 |
| `modules/home/default.nix` | `yourname` |
| `modules/home/git.nix` | 姓名、邮箱 |
| `modules/home/shell.nix` | 主机名（alias 里） |

改主机名时：
```bash
mv hosts/myhostname hosts/yourhostname
# 同步更新 flake/hosts.nix 里的键名和 ../hosts/myhostname 路径
# 同步更新 flake/checks.nix 里的 myhostname
```

### 第四步：disko 格式化磁盘

> ⚠ **会清除磁盘全部数据**，确认 `device` 路径正确后再执行。

```bash
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  /tmp/cfg/modules/nixos/disk.nix
```

### 第五步：创建 @blank 快照（只需一次）

```bash
mount -t btrfs /dev/mapper/cryptroot /mnt/btrfs_tmp
btrfs subvolume snapshot -r /mnt/btrfs_tmp/@ /mnt/btrfs_tmp/@blank
umount /mnt/btrfs_tmp
```

**不要往 `@blank` 里写东西**，它是每次重启 rollback 的来源。

### 第六步：生成硬件配置

```bash
sudo nixos-generate-config --show-hardware-config \
  > /tmp/cfg/hosts/myhostname/hardware.nix
```

### 第七步：初始化 /persist

```bash
sudo mkdir -p /mnt/persist/etc/ssh
sudo mkdir -p /mnt/persist/etc/NetworkManager/system-connections
sudo systemd-machine-id-setup --root=/mnt/persist
sudo ssh-keygen -A -f /mnt/persist
```

### 第八步：安装

```bash
sudo nixos-install --flake /tmp/cfg#myhostname --no-root-passwd
```

### 第九步：重启

```bash
sudo reboot
```

重启流程：Limine 菜单（3 秒）→ 输入 LUKS 密码 → btrfs rollback → 系统启动。

---

## 如何修改配置

### 修改系统配置（NixOS）

在 `modules/nixos/` 下的文件直接修改，或新建文件后在 `hosts/myhostname/default.nix` 里加一行 import。

```bash
sudo nixos-rebuild switch --flake .#myhostname
```

### 修改用户配置（home-manager）

在 `modules/home/` 下的文件直接修改。新增程序配置时，新建文件再加到 `modules/home/default.nix` 的 `imports` 里：

```nix
# modules/home/default.nix
imports = [
  ./packages.nix
  ./shell.nix
  ./git.nix
  ./neovim.nix  # ← 新加
];
```

```bash
sudo nixos-rebuild switch --flake .#myhostname
# home-manager 配置立即生效，无需重启
```

### 新增机器

1. 复制 `hosts/myhostname/` → `hosts/newhost/`
2. 修改 `hosts/newhost/default.nix` 里的 `hostName`
3. 在 `flake/hosts.nix` 里复制 `myhostname` 的块，改名为 `newhost`
4. 在 `flake/checks.nix` 里加对应的 check 条目
5. 生成新机器的 `hardware.nix`

### 添加 flake 新输出

在 `flake/` 下新建文件，写 flake-parts 模块，在 `flake.nix` 的 `imports` 里加上它：

```nix
# flake/packages.nix 示例
{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.mytool = pkgs.callPackage ../pkgs/mytool {};
  };
}
```

---

## 日常维护命令

```bash
# 更新配置
sudo nixos-rebuild switch --flake .#myhostname

# 更新所有 flake 依赖后构建
nix flake update && sudo nixos-rebuild switch --flake .#myhostname

# 进入维护 shell
nix develop

# 格式化所有 nix 文件
nix fmt

# 检查配置能否构建（不需要 root）
nix flake check

# 可视化依赖树
nix-tree .#nixosConfigurations.myhostname

# 对比两次构建的差异
nvd diff /run/current-system result
```

---

## 故障排除

**Limine 不出现**：确认 BIOS 里 Secure Boot 已关闭；检查 `/boot` 是否挂载到 ESP。

**LUKS 解密失败**：确认 `modules/nixos/boot.nix` 里的标签 `LUKS` 与 `modules/nixos/disk.nix` 里 `partitions.luks.label` 完全一致。

**@blank 不存在导致启动循环**：进 Live 环境，解锁 LUKS，挂载 btrfs，补做第五步。

**home-manager 配置不生效**：确认 `modules/home/default.nix` 里的用户名和 `modules/nixos/system.nix` 里的 `users.users` 键名完全一致。

**nix flake check 失败**：单独跑 `nix build .#checks.x86_64-linux.nixos-myhostname --keep-failed` 看完整错误。
