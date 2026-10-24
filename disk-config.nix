{ ... }:
{
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108974275";
    content = {
      type = "gpt";
      partitions = {
        MBR = {
          priority = 0;
          size = "1M";
          type = "EF02";
        };
        root = {
          priority = 1;
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
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
                mountpoint = "/.swapvol";
                swap.swapfile.size = "1G";
              };
            };
          };
        };
      };
    };
  };
}
