# ── modules/nixos/system.nix ──────────────────────────────────────────────────
# ⚠ nixpkgs.config.allowUnfree 不在这里设。
#   flake/overlays.nix 里通过 perSystem _module.args.pkgs 配好了 allowUnfree，
#   mkHost 用 withSystem 把那份 pkgs 注入为 nixpkgs.pkgs。
#   当 nixpkgs.pkgs 由外部提供时，NixOS 会忽略 nixpkgs.config 并产生警告。
# ─────────────────────────────────────────────────────────────────────────────
{ pkgs, myLib, ... }:
{
  time.timeZone = "Asia/Shanghai"; # ⚠ 按需修改
  i18n.defaultLocale = "zh_CN.UTF-8";

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  users.users.dwoo = myLib.mkUser { # ⚠ 改 yourname（key 也要改）
    username        = "dwoo";       # ⚠ 同上
    shell           = pkgs.bash;
    hashedPassword = "$y$j9T$OkuoNFPDeO8RYMqNet8Kd.$AN0jTBbSbV7Qwk3mzJZQJ1f7Cih45xR0Koo2g7xtWG3";       # ⚠ 首次登录后立即修改
  };

  users.users.root.hashedPassword = "$y$j9T$OkuoNFPDeO8RYMqNet8Kd.$AN0jTBbSbV7Qwk3mzJZQJ1f7Cih45xR0Koo2g7xtWG3";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
    trusted-users         = [ "root" "dwoo" ]; # ⚠ 同步修改
  };

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 14d";
  };

  environment.systemPackages = with pkgs; [ git curl wget ];
}
