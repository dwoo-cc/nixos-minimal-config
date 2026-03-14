{
  description = "NixOS — Limine + LUKS + Btrfs + Impermanence + disko + home-manager，flake-parts + 模块注册表";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./flake/lib.nix       # ← 先实例化 myLib，其他模块才能用
        ./flake/overlays.nix
        ./flake/modules.nix   # ← 发布 flake.modules.nixos.* / flake.modules.home.*
        ./flake/hosts.nix
        ./flake/devshell.nix
        ./flake/formatter.nix
        ./flake/checks.nix
      ];
    };
}
