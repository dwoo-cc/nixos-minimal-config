# ── lib/default.nix ───────────────────────────────────────────────────────────
# 自定义 lib 的组装入口。
#
# 用 lib.fix 实现 self 引用：mkHost 需要把 myLib 注入 specialArgs，
# 所以它必须拿到 myLib 自身。lib.fix = f: let x = f x; in x，
# 利用 Nix 惰性求值安全地形成自引用，不会无限递归。
# ─────────────────────────────────────────────────────────────────────────────
{ lib, inputs }:

let
  root = ../.;
in
  lib.fix (self: {
    autoImport = import ./autoImport.nix { inherit lib; };
    mkUser     = import ./mkUser.nix     { inherit lib; };
    registry   = import ./registry.nix   { inherit lib root; };
  } // import ./mkHost.nix { inherit lib inputs; myLib = self; })
