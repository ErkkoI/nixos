{ ... }:
{
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.gc.options = "--delete-older-than 30d";
    nix.settings.auto-optimise-store = true;
}
