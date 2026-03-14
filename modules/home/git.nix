# ── modules/home/git.nix ──────────────────────────────────────────────────────
{ ... }:
{
  programs.git = {
    enable = true;
    userName  = "Your Name";        # ⚠ 改
    userEmail = "you@example.com";  # ⚠ 改
    extraConfig = {
      pull.rebase        = true;
      init.defaultBranch = "main";
    };
  };
}
