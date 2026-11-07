{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      disko,
      nix-minecraft,
      ...
    }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        pannu = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            nix-minecraft.nixosModules.minecraft-servers
            {
              nixpkgs.overlays = [ nix-minecraft.overlay ];
              nixpkgs.config.allowUnfreePredicate =
                pkg:
                builtins.elem (nixpkgs.lib.getName pkg) [
                  "minecraft-server"
                ];
            }
            ./pannu.nix
          ];
        };
        torni = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            disko.nixosModules.disko
            ./torni.nix
          ];
        };
      };
      devShells.x86_64-linux.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          helix
          nixfmt
          nixd
        ];
      };
    };
}
