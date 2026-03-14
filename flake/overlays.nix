# ── flake/overlays.nix ────────────────────────────────────────────────────────
# flake-parts 模块：管理 nixpkgs overlay 和全局 pkgs 配置。
#
# 职责：
#   1. 暴露 flake.overlays（供外部 flake 使用）
#   2. 在 perSystem 里配置 nixpkgs（allowUnfree、overlays 等）
#      ——配置后 perSystem 里的 pkgs 和 NixOS 里的 pkgs 来自同一实例。
# ─────────────────────────────────────────────────────────────────────────────
{ inputs, ... }:
{
  # 暴露给外部 flake 使用的 overlay（当前为空，按需添加）
  flake.overlays.default = _final: _prev: {
    # 在这里覆盖或添加包，例如：
    # mypackage = final.callPackage ../pkgs/mypackage {};
  };

  # 将 overlay 应用到 perSystem 的 pkgs 上
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        # 引用上面定义的 overlay
        # inputs.self.overlays.default
      ];
    };
  };
}
