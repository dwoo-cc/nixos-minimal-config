# ── flake/modules.nix ─────────────────────────────────────────────────────────
# flake-parts 模块：把模块注册表里的所有模块发布为 flake 输出。
#
# 发布后可以通过以下方式访问：
#   inputs.self.modules.nixos.disk         → NixOS disk 模块路径
#   inputs.self.modules.home.git           → home-manager git 模块路径
#
# 如果外部 flake 想复用这里的模块：
#   inputs.mynixos.modules.nixos.impermanence
#
# 这里不手写模块列表——直接从 myLib.registry.allModules 取，
# 和注册表保持单一来源，modules/ 目录下加文件后这里自动出现。
# ─────────────────────────────────────────────────────────────────────────────
{ myLib, ... }:
{
  flake.modules = {
    nixos = myLib.registry.allModules.nixos;
    home  = myLib.registry.allModules.home;
  };
}
