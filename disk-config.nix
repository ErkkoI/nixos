{ ... }:
{
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108974275";
    content = {
      type = "gpt";
      partitions = {
        MBR = {
          size = "1M";
          type = "EF02";
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "nixos" "-f" ];
            mountpoint = "/";
            subvolumes = {
              "/root" = {
                mountOptions = [ "compress=zstd:1" "noatime" ];
                mountpoint = "/";
              };
              "/home" = {
                mountOptions = [ "compress=zstd:1" "noatime" ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [ "compress=zstd:1" "noatime" ];
                mountpoint = "/nix";
              };
              "/swap" = {
                mountpoint = "/swap";
                swap.swapfile.size = "1G";
              };
            };
          };
        };
      };
    };
  };
}
