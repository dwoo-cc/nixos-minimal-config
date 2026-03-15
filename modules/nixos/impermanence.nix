# ── modules/nixos/impermanence.nix ────────────────────────────────────────────
{ ... }:
{
  programs.fuse.userAllowOther = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
       "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
      "/var/db/sudo/lectured"
      { directory = "/etc/NetworkManager/system-connections"; mode = "0700"; }
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/nix" "/home" "/persist" ];
  };
}
