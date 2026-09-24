# Replace or extend this with the output from nixos-generate-config during the
# installation. This file intentionally contains no disk UUIDs or host paths.
{ ... }:

{
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "xhci_pci"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ "dm_crypt" ];
  boot.kernelModules = [ "virtio_gpu" ];

  # Filesystems and the initrd LUKS mapping are declared in disco.nix.

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
}
