{ ... }:
{
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108974275";
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02";
        };
        root = {
          size = "100%";

          content = {
            type = "btrfs";
            extraArgs = [ "-f" ]; # Override existing partition
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = ["subvol=root" "compress=zstd" "noatime"];
              };
              "/swap" = {
                mountpoint = "/swap";
                swap.swapfile.size = "2G";
              };
            };
          };
        };
      };
    };
  };
}
