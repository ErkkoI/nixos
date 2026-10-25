{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
    };
  };
  outputs =
    {
      nixpkgs,
      disko,
      nix-minecraft
      ...
    }:
    {
      nixosConfigurations.pannu = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [ nix-minecraft.overlay ];
          }
          ./configuration.nix
        ];
      };
    };
}
