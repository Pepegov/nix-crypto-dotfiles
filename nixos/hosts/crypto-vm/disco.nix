{ ... }:

{
  # Applied only by disko, this recreates the complete target disk. The VM's
  # virtio disk is deliberately named explicitly to make the install target
  # reviewable. Do not run disko against a host disk.
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          cryptroot = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraFormatArgs = [ "--type" "luks2" ];
              # With no passwordFile or keyFile, disko prompts for the initial
              # LUKS passphrase. It is not retained in the Nix store or Git.
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
