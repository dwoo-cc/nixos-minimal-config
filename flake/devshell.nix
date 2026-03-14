# ── flake/devshell.nix ────────────────────────────────────────────────────────
# flake-parts 模块：维护配置用的开发 shell。
#
# 用法：nix develop
# ─────────────────────────────────────────────────────────────────────────────
{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        nixfmt-rfc-style  # nix 代码格式化
        nix-tree          # 依赖树可视化：nix-tree .#nixosConfigurations.myhostname
        nvd               # 两个 NixOS closure 对比：nvd diff old new
      ];
    };
  };
}
