{
  modulesPath,
  lib,
  pkgs,
  config,
  options,
  specialArgs,
  _class,
  _prefix,
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys =
  [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeBFiv1ggn3jdQIjlUeXaSAPak7nMalRaHVjjcLv7BH erkkoi@cachyos-x8664"
  ];

  system.stateVersion = "26.05";
}
