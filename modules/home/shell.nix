# ── modules/home/shell.nix ────────────────────────────────────────────────────
{ ... }:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      ll  = "ls -lahF";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos#myhostname"; # ⚠ 改主机名
    };
  };
}
