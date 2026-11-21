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
    ./opencloud.nix
    ./minecraft.nix
    ./wireguard.nix
  ];
  time.timeZone = "UTC";
  nix.gc.options = "--delete-older-than 7d";
  nix.settings.max-jobs = 1;
  boot.zswap.enable = true;
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
  };
  services.journald.extraConfig = "SystemMaxUse=200M";
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
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      PermitTunnel = "no";
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };
  users.users.erkkoi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPsGRR6hn6KG6/qlGejQXeP2pAe811qJFuEoMFdznNv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqwBPCqs921XN4mRHfJDy64x47t6n0SXoSDaPFlWnGH"
  ];
  environment.systemPackages = with pkgs; [
    gitMinimal
  ];
}
