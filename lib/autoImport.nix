# ── lib/autoImport.nix ────────────────────────────────────────────────────────
# 目录自动扫描工具。
#
# 导出：
#   fromDir  dir { exclude ? [] }   → 扫一个目录，返回 .nix 文件路径列表
#   fromDirs dirs { exclude ? [] }  → 扫多个目录，结果合并
#
# 规则：
#   - 只处理直接子文件（不递归），不处理子目录
#   - 只返回后缀为 .nix 的文件
#   - exclude 传文件名（不带路径），用于排除自身（如 "default.nix"）
#   - 把后缀改为 .nix.disabled 可临时禁用某个模块，不会被扫到
# ─────────────────────────────────────────────────────────────────────────────
{ lib }:

rec {
  fromDir = dir: { exclude ? [] }:
    lib.pipe (builtins.readDir dir) [
      # 只要普通文件（跳过子目录、符号链接等）
      (lib.filterAttrs (_: type: type == "regular"))
      # 只要 .nix 后缀
      (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name))
      # 排除指定文件名
      (lib.filterAttrs (name: _: !(lib.elem name exclude)))
      # 文件名 → 绝对路径（path 类型，不经过 store）
      (lib.mapAttrsToList (name: _: dir + "/${name}"))
    ];

  fromDirs = dirs: opts:
    lib.concatMap (dir: fromDir dir opts) dirs;
}
