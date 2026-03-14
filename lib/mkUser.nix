# ── lib/mkUser.nix ────────────────────────────────────────────────────────────
# 构建 users.users.<name> 的 attrset，统一默认值，消除各 host 之间的重复。
#
# 用法（在 modules/nixos/system.nix 或 host-specific 文件里）：
#
#   users.users.yourname = myLib.mkUser {
#     username    = "yourname";
#     shell       = pkgs.fish;
#     hashedPassword = "...";     # mkpasswd -m yescrypt 生成
#   };
#
# 参数说明：
#   username        必填，用于 description 默认值
#   description     可选，默认等于 username
#   extraGroups     可选，默认 [ "wheel" "networkmanager" ]
#   shell           可选，默认 null（继承系统默认）
#   hashedPassword  可选，与 initialPassword 二选一
#   initialPassword 可选，不填则两个密码字段都不设（需要自行处理）
#   sshKeys         可选，追加到 authorizedKeys.keys
# ─────────────────────────────────────────────────────────────────────────────
{ lib }:

{ username
, description     ? username
, extraGroups     ? [ "wheel" "networkmanager" ]
, shell           ? null
, hashedPassword  ? null
, initialPassword ? null
, sshKeys         ? []
}:

assert lib.assertMsg
  (hashedPassword == null || initialPassword == null)
  "mkUser: hashedPassword 和 initialPassword 只能设一个，不能同时设。";

{
  isNormalUser = true;
  inherit description extraGroups;
}
# 以下字段只有非 null 时才写入，避免与 NixOS 默认值冲突
// lib.optionalAttrs (shell           != null) { inherit shell; }
// lib.optionalAttrs (hashedPassword  != null) { inherit hashedPassword; }
// lib.optionalAttrs (initialPassword != null) { inherit initialPassword; }
// lib.optionalAttrs (sshKeys         != []  ) { openssh.authorizedKeys.keys = sshKeys; }
