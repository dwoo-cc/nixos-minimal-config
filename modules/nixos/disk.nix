# ── modules/nixos/disk.nix ────────────────────────────────────────────────────
# disko 分区方案：GPT → EFI(1G) + LUKS2 → btrfs 子卷
#
# 子卷布局：
#   @         →  /          每次重启清空（rollback）
#   @blank               只读快照，rollback 的来源，安装时手动创建
#   @nix      →  /nix       Nix store，不清空
#   @home     →  /home      用户目录，不清空
#   @persist  →  /persist   opt-in 持久化根目录
#   @log      →  /var/log   日志，不清空
#
# ⚠ 将 device 改为你的实际磁盘（lsblk 查看）
# ─────────────────────────────────────────────────────────────────────────────
{ ... }:
{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1"; # ⚠ 改这里
    content = {
      type = "gpt";
      partitions = {

        ESP = {
          label = "ESP";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        luks = {
          label = "LUKS";
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "nixos" ];
              subvolumes = {
                "@"        = { mountpoint = "/";        mountOptions = [ "compress=zstd" "noatime" ]; };
                "@blank"   = {};
                "@nix"     = { mountpoint = "/nix";     mountOptions = [ "compress=zstd" "noatime" ]; };
                "@home"    = { mountpoint = "/home";    mountOptions = [ "compress=zstd" "noatime" ]; };
                "@persist" = { mountpoint = "/persist"; mountOptions = [ "compress=zstd" "noatime" ]; };
                "@log"     = { mountpoint = "/var/log"; mountOptions = [ "compress=zstd" "noatime" ]; };
              };
            };
          };
        };

      };
    };
  };
}
