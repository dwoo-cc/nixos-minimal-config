# ── flake/hosts.nix ───────────────────────────────────────────────────────────
# flake-parts 模块：注册所有机器。
#
# myLib.mapHosts 自动处理：
#   - 调用 nixpkgs.lib.nixosSystem
#   - 注入 perSystem pkgs（withSystem）
#   - 注入 myLib 到 specialArgs
#   - 加载 disko / impermanence / home-manager 模块
#   - 定位 hosts/<hostname>/ 目录
#
# 新增机器：
#   1. 复制 hosts/myhostname/ → hosts/newhost/
#   2. 修改 hosts/newhost/default.nix 里的 hostName
#   3. 在 hosts 里加一行 newhost = {};
# ─────────────────────────────────────────────────────────────────────────────
{ withSystem, myLib, ... }:
{
  flake.nixosConfigurations = myLib.mapHosts {
    inherit withSystem;

    hosts = {
      onyx = {};  # ⚠ 改成你的主机名（同时改 hosts/ 目录名）

      # 新机器示例：
      # laptop = {};
      # server = { system = "aarch64-linux"; };
      # workstation = {
      #   extraModules = [ ./hosts/workstation/nvidia.nix ];
      # };
    };
  };
}
