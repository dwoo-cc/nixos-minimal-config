# ── flake/checks.nix ──────────────────────────────────────────────────────────
# flake-parts 模块：从 nixosConfigurations 自动生成 checks。
#
# 不需要手动维护机器列表——每注册一台机器，check 自动出现。
#
# 用法：
#   nix flake check             # 构建所有机器的 system.build.toplevel
#   nix flake check --keep-going  # 失败后继续跑其他机器
# ─────────────────────────────────────────────────────────────────────────────
{ inputs, lib, ... }:
{
  flake.checks =
    let
      configs = inputs.self.nixosConfigurations;

      # 按 system 分组：{ "x86_64-linux" = { myhostname = cfg; ... }; ... }
      bySystem = lib.foldlAttrs (acc: name: cfg:
        let system = cfg.config.nixpkgs.hostPlatform.system;
        in acc // {
          ${system} = (acc.${system} or {}) // { ${name} = cfg; };
        }
      ) {} configs;
    in
    # 每台机器 → checks.<system>.nixos-<hostname> = system.build.toplevel
    lib.mapAttrs (_system: hostCfgs:
      lib.mapAttrs' (name: cfg:
        lib.nameValuePair "nixos-${name}" cfg.config.system.build.toplevel
      ) hostCfgs
    ) bySystem;
}
