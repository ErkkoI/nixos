{ ... }:
{
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.gc.options = "--delete-older-than 7d";
    nix.settings.auto-optimise-store = true;
}
