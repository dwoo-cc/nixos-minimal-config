{ ... }:
{
  disko.devices.nodev."/boot" = {
    fsType = "vfat";
    device = "/dev/nvme0n1p1"; # ⚠ 你的 ESP 分区
    mountOptions = [ "fmask=0077" "dmask=0077" ];
  };

  disko.devices.disk.nixos = {
    device = "/dev/nvme0n1p4"; # ⚠ 你给 NixOS 划的分区
    content = {
      type = "luks";
      name = "cryptroot";
      settings.allowDiscards = true;
      content = {
        type      = "btrfs";
        extraArgs = [ "-f" "-L" "nixos" ];
        subvolumes = {
          "@"        = { mountpoint = "/";        mountOptions = [ "compress=zstd" "noatime" ]; };
          "@nix"     = { mountpoint = "/nix";     mountOptions = [ "compress=zstd" "noatime" ]; };
          "@home"    = { mountpoint = "/home";    mountOptions = [ "compress=zstd" "noatime" ]; };
          "@persist" = { mountpoint = "/persist"; mountOptions = [ "compress=zstd" "noatime" ]; };
          "@log"     = { mountpoint = "/var/log"; mountOptions = [ "compress=zstd" "noatime" ]; };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
