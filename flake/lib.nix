# ── flake/lib.nix ─────────────────────────────────────────────────────────────
# flake-parts 模块：实例化 lib/ 并全局注入。
#
# 效果：
#   - 所有 flake-parts 模块（flake/*.nix）可通过参数 `myLib` 直接使用
#   - 所有 NixOS 模块通过 specialArgs.myLib 使用（mkHost 自动传入）
#   - 所有 home-manager 模块通过 extraSpecialArgs.myLib 使用
#   - flake.lib 暴露给外部 flake（如果有人 inputs.self.lib）
# ─────────────────────────────────────────────────────────────────────────────
{ inputs, lib, ... }:
let
  myLib = import ../lib { inherit lib inputs; };
in
{
  # 注入到所有 flake-parts 模块的参数中
  _module.args.myLib = myLib;

  # 暴露给外部（可选）
  flake.lib = myLib;
}
