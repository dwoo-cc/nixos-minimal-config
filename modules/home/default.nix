# ── modules/home/default.nix ──────────────────────────────────────────────────
# home-manager 配置的 NixOS 层入口。
# 通过 myLib.registry.get.home 按名声明所需的 HM 子模块。
# 往 modules/home/ 里加文件后，这里按名引用即可。
# ─────────────────────────────────────────────────────────────────────────────
{ inputs, myLib, ... }:
{
  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    extraSpecialArgs = { inherit inputs myLib; };

    users.yourname = { myLib, ... }: { # ⚠ 改成你的用户名
      home.username      = "yourname";       # ⚠ 同上
      home.homeDirectory = "/home/yourname"; # ⚠ 同上

      # 按名声明所需的 home-manager 子模块
      # 加新模块：在 modules/home/ 下新建文件，在这里加一个名字即可
      imports = myLib.registry.get.home [ "packages" "shell" "git" ];

      home.stateVersion = "25.05";
    };
  };
}
