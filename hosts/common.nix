{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  users.users.erkkoi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  security.sudo.execWheelOnly = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
  ];

  system.stateVersion = "26.05";
}
