# ── modules/home/packages.nix ─────────────────────────────────────────────────
# 用户级软件包。systemPackages 是系统全局的，这里的包只属于当前用户。
# ─────────────────────────────────────────────────────────────────────────────
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    unzip
  ];
}
