{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./caddy.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc.options = "--delete-older-than 7d";
  nix.settings.auto-optimise-store = true;
  system.autoUpgrade = {
    enable = true;
    # Disable adding the --upgrade flag. Not used with flakes.
    # Flake update is done in a GH action.
    upgrade = false;
    flake = "github:erkkoi/nixos#pannu";
    dates = "03:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "05:00";
    };
    runGarbageCollection = true;
  };
  networking.firewall.enable = true;
  networking.hostName = "pannu";
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
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
  environment.systemPackages = with pkgs; [
    gitMinimal
  ];
  system.stateVersion = "26.05";
}
