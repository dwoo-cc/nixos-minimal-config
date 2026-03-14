# 安装前用以下命令生成并替换此文件：
#   sudo nixos-generate-config --show-hardware-config > hosts/myhostname/hardware.nix
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # AMD 改为 kvm-amd
  nixpkgs.hostPlatform = "x86_64-linux";
}
