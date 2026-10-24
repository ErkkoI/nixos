{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./opencloud.nix
    ./nix.nix
  ];
  system.autoUpgrade = {
    enable = true;
    flake = "github:erkkoi/nixos";
    dates = "03:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
    runGarbageCollection = true;
  };
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDJ2drXN6bgX3tiUK+G6IfUeq7KwtpcjjyY+9QhIEyPmzHc/wEhE2leWyJB9RqjVw6CjkRVctBdKh9DeikcizLOxGrDyltCLQdQDg+tgUbCCT34WT4RJUE8icZ7BQ4h8l6MWRTLeFGNnn8e73b2UMcTikyi4S+8NNcqMqm7QUP4fp2VJAn9vRs4SulPHU2RMIim5q1fm/vvPU3NT4jALsYCbKU7jWSUznH14SAlNxdp7AzJP1iRyC+G+uI/q/gtKzz9Cv21xe4SNpALm0lHQ7NK27FhnzxvlnW0JRxInZQ70dGW1cU7R5zO6qPq5qSrO9oYh1B8HBJLkllqS43OQdNPUlcM1HjH+5oOsRWu4LIla+acP/vKs2C3q4G0dDwL0qHFgDVxIPbE1cl7/LG9c4wZkYhtcLcBgX7XdvKpm4CGEQEMjce7JfbQQwVtIpiz18Tgi4gRtP6GZmDotUkvzqL24oJwIUZsfh2Do0no7UgbAdDmthuNj1fVQrdjTARQNMFhNA60LxnzSFOqNm+qfOAw1+jRWzE5Yd41jj32y7Y4/zgQ/H41u9vaRHzqw9oA1ir9RGCf3axCJNv/76cZ4tizZc9GsVBTJrJypN8PPx+vjl1TFmxwf5MXIkkDCR/QZQKgWN9dWFkSSZfSk8umdYrfXq9ifdMdzJiJVQG4jUmNw== personal@erkkoihalainen.fi"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
  system.stateVersion = "26.05";
}
