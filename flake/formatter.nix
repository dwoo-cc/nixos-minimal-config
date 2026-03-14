# ── flake/formatter.nix ───────────────────────────────────────────────────────
# flake-parts 模块：声明 nix fmt 用的格式化工具。
#
# 用法：
#   nix fmt                     # 格式化整个 flake
#   nix fmt -- flake.nix        # 格式化单个文件
# ─────────────────────────────────────────────────────────────────────────────
{ ... }:
{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-rfc-style;
  };
}
