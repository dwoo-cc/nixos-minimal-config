{ ... }:
{
  programs.git = {
    enable    = true;
    userName  = "Your Name";        # ⚠ 改
    userEmail = "you@example.com";  # ⚠ 改
    settings = {                    # ← extraConfig 改成 settings
      pull.rebase        = true;
      init.defaultBranch = "main";
    };
  };
}
