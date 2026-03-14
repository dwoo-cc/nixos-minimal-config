# ── lib/mkHost.nix ────────────────────────────────────────────────────────────
# nixosSystem 工厂函数。
#
# 关键设计：
#   用 withSystem system (...) 包裹整个 nixosSystem，让 flake-parts 在正确的
#   perSystem 上下文里求值并拿到 pkgs，再通过 { nixpkgs.pkgs = pkgs; } 注入。
#   不把 system 传给 nixosSystem——那会设置 nixpkgs.system，与
#   hardware.nix 里的 nixpkgs.hostPlatform 产生冲突（NixOS 25.05+ 直接报错）。
#   nixpkgs.hostPlatform 由每台机器的 hardware.nix 自行声明即可。
#
# system 参数：
#   只用于调用 withSystem（决定用哪个 perSystem 的 pkgs），
#   必须与 hardware.nix 里 nixpkgs.hostPlatform 的值一致。
# ─────────────────────────────────────────────────────────────────────────────
{ lib, inputs, myLib }:

let
  defaultSharedModules = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
  ];

  mkHost =
    { withSystem
    , hostname
    , system          ? "x86_64-linux"
    , sharedModules   ? defaultSharedModules
    , extraModules    ? []
    , extraSpecialArgs ? {}
    }:
    # withSystem 在 system 对应的 perSystem 上下文里求值，拿到配好 overlay /
    # allowUnfree 等的 pkgs 实例，保证全局只有一份 nixpkgs import。
    withSystem system ({ pkgs, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        # 不传 system —— hardware.nix 通过 nixpkgs.hostPlatform 声明平台。
        # 两者同时存在会触发 NixOS 的冲突断言。
        specialArgs = { inherit inputs myLib; } // extraSpecialArgs;

        modules = sharedModules ++ [
          # 直接注入 pkgs，不走 config.nixpkgs.hostPlatform 的懒求值路径
          { nixpkgs.pkgs = pkgs; }

          (../hosts + "/${hostname}")
        ] ++ extraModules;
      }
    );

  mapHosts =
    { withSystem
    , hosts
    , sharedModules ? defaultSharedModules
    }:
    lib.mapAttrs (hostname: cfg:
      mkHost ({ inherit withSystem hostname sharedModules; } // cfg)
    ) hosts;

in { inherit mkHost mapHosts; }
