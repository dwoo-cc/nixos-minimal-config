# ── modules/nixos/boot.nix ────────────────────────────────────────────────────
{ lib, ... }:
{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;

    limine = {
      enable = true;
      maxGenerations = 10;
      extraConfig = ''
        TIMEOUT=3
        VERBOSE=no
      '';
    };
  };

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/LUKS";
    allowDiscards = true;
  };

  boot.supportedFilesystems     = [ "btrfs" "vfat" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  # ── Btrfs root rollback ─────────────────────────────────────────────────────
  # LUKS 解锁后、/ 挂载前执行：归档旧 @，从 @blank 重建。
  #
  # ⚠ initrd 里跑的是 busybox ash，不是 bash。
  #   - 不能用 $'\n'（bash ANSI-C quoting），必须用字面换行设 IFS
  #   - 不能用 [[ ]]，只能用 [ ]
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount -t btrfs /dev/mapper/cryptroot /btrfs_tmp

    # 递归删除 btrfs 子卷（先删子再删父）
    delete_subvol_recursively() {
      # 用字面换行设 IFS —— busybox ash 不支持 $'\n'
      IFS="
"
      for i in $(btrfs subvolume list -o "$1" | awk '{print $NF}'); do
        delete_subvol_recursively "/btrfs_tmp/$i"
      done
      unset IFS
      btrfs subvolume delete "$1"
    }

    if [ -e /btrfs_tmp/@ ]; then
      mkdir -p /btrfs_tmp/old_roots
      stamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
      mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$stamp"
    fi

    for old in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30 2>/dev/null); do
      delete_subvol_recursively "$old"
    done

    btrfs subvolume snapshot /btrfs_tmp/@blank /btrfs_tmp/@
    umount /btrfs_tmp
  '';
}
