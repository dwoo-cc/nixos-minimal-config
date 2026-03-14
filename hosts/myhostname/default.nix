# ── hosts/myhostname/default.nix ──────────────────────────────────────────────
# 通过 myLib.registry 按名声明所需的 NixOS 模块。
#
# 层级说明：
#   registry.get.nixos → 纯 NixOS 模块（disk / boot / system / impermanence）
#   ../../modules/home/default.nix → HM 的 NixOS 入口（单独引用，不经注册表）
#     └── 内部用 registry.get.home 加载 HM 子模块（packages / shell / git）
#
# 两种写法均可，选一种：
#
# 写法 A（按名列出，清楚看到每台机器加载了什么）：
#   imports =
#     [ ./hardware.nix ]
#     ++ myLib.registry.get.nixos [ "disk" "boot" "system" "impermanence" ]
#     ++ [ ../../modules/home/default.nix ];
#
# 写法 B（profile 预设，一行搞定）：
#   let p = myLib.registry.fromProfile "base"; in
#   imports = [ ./hardware.nix ] ++ p.nixos ++ [ ../../modules/home/default.nix ];
#
# 当前使用写法 A。
# ─────────────────────────────────────────────────────────────────────────────
{ myLib, ... }:
{
  imports =
    [ ./hardware.nix ]
    ++ myLib.registry.get.nixos [ "disk" "boot" "system" "impermanence" ]
    ++ [ ../../modules/home/default.nix ];

  networking.hostName = "myhostname"; # ⚠ 改成你的主机名
  system.stateVersion = "25.05";
}
