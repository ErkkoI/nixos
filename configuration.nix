{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # nix.gc.options = "--delete-older-than 7d";
  # nix.settings.auto-optimise-store = true;
  #system.autoUpgrade = {
  #  enable = true;
  #  flake = "github:erkkoi/nixos";
  #  dates = "03:00";
  #  randomizedDelaySec = "45min";
  #  allowReboot = true;
  #  runGarbageCollection = true;
  #};
  networking.firewall.enable = true;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "erkkoi" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };
  users.users.erkkoi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPsGRR6hn6KG6/qlGejQXeP2pAe811qJFuEoMFdznNv"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  # services.btrfs.autoScrub = {
  #   enable = true;
  #   interval = "weekly";
  #   fileSystems = [ "/" ];
  # };
  system.stateVersion = "26.05";
}
