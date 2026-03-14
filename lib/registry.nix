# ── lib/registry.nix ──────────────────────────────────────────────────────────
# 模块注册表。
#
# 职责：
#   1. 扫描 modules/nixos/ 和 modules/home/，把文件名（去掉 .nix）映射到路径
#   2. 提供按名查询（get.nixos / get.home），名字错误时给出清晰的错误信息
#   3. 维护 profiles：预定义的模块组合，方便 host 声明"我是什么角色"
#   4. 暴露 allModules，让 flake/modules.nix 直接用来发布 flake.modules.*
#
# 用法示例（在 NixOS 模块或 host 文件里）：
#
#   imports =
#     [ ./hardware.nix ]
#     ++ myLib.registry.get.nixos [ "disk" "boot" "system" "impermanence" ]
#     ++ myLib.registry.get.home  [ "packages" "shell" "git" ];
#
#   # 或者用预设 profile 一次性取所有模块：
#   imports =
#     [ ./hardware.nix ]
#     let p = myLib.registry.fromProfile "base"; in imports = [ ./hardware.nix ] ++ p.nixos ++ p.home;
#
# 注意：
#   - 只扫直接子文件，不递归
#   - 排除 default.nix（home 入口不参与注册）
#   - 文件名改成 .nix.disabled 可临时禁用，不会被扫到
# ─────────────────────────────────────────────────────────────────────────────
{ lib, root }:

let
  # 扫描某个目录，返回 { moduleName = /path/to/module.nix; }
  # 文件名去掉 .nix 后缀作为模块名
  scanDir = dir:
    lib.pipe (builtins.readDir dir) [
      (lib.filterAttrs (_: type: type == "regular"))
      (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name))
      (lib.filterAttrs (name: _: name != "default.nix"))
      (lib.mapAttrs' (name: _:
        lib.nameValuePair
          (lib.removeSuffix ".nix" name) # "disk.nix" → "disk"
          (dir + "/${name}")             # → /abs/path/to/disk.nix
      ))
    ];

  # 全量模块映射表
  # { nixos = { disk = <path>; boot = <path>; ... };
  #   home  = { git  = <path>; shell = <path>; ... }; }
  allModules = {
    nixos = scanDir (root + "/modules/nixos");
    home  = scanDir (root + "/modules/home");
  };

  # ── 按名查询，带错误提示 ──────────────────────────────────────────────────
  # names 是字符串列表，返回对应路径列表
  # 给定名字不存在时 nix eval 阶段就报错，并列出可用的模块名
  makeGetter = category: modules: names:
    map (name:
      assert lib.assertMsg (modules ? ${name}) ''
        registry.get.${category}: 未知模块 "${name}"
        可用的 ${category} 模块有: ${lib.concatStringsSep ", " (lib.attrNames modules)}
      '';
      modules.${name}
    ) names;

  get = {
    nixos = makeGetter "nixos" allModules.nixos;
    home  = makeGetter "home"  allModules.home;
  };

  # ── Profiles（预定义模块组合）─────────────────────────────────────────────
  # 每个 profile 声明它需要哪些 nixos 模块和 home 模块（按名引用）。
  # host 文件可以直接 fromProfile "base" 而不用手写完整列表。
  #
  # 修改 profile 里的名字列表后，所有用该 profile 的机器都会同步更新。
  profiles = {
    # 最小化基础配置：磁盘 + 引导 + 用户 + 持久化 + 基础 home
    base = {
      nixos = [ "disk" "boot" "system" "impermanence" ];
      home  = [ "packages" "shell" "git" ];
    };

    # 预留位置：可以扩展更多 profile
    # desktop = {
    #   nixos = [ "disk" "boot" "system" "impermanence" "desktop" "fonts" ];
    #   home  = [ "packages" "shell" "git" "editor" "browser" ];
    # };
    # server = {
    #   nixos = [ "disk" "boot" "system" "impermanence" "openssh" "firewall" ];
    #   home  = [ "packages" "shell" "git" ];
    # };
  };

  # fromProfile 返回 { nixos = [paths...]; home = [paths...]; }
  # 方便在 imports 里直接展开：
  #   let p = myLib.registry.fromProfile "base";
  #   in imports = [ ./hardware.nix ] ++ p.nixos ++ p.home;
  fromProfile = profileName:
    assert lib.assertMsg (profiles ? ${profileName}) ''
      registry.fromProfile: 未知 profile "${profileName}"
      可用的 profiles: ${lib.concatStringsSep ", " (lib.attrNames profiles)}
    '';
    let p = profiles.${profileName}; in {
      nixos = get.nixos p.nixos;
      home  = get.home  p.home;
    };

in {
  inherit allModules profiles get fromProfile;
}
