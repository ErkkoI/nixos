{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
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
      nixpkgs-unstable,
      ...
    }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgsUnstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages.x86_64-linux.t3code-nightly = pkgsUnstable.callPackage ./pkgs/t3code-nightly { };
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
            ./hosts/common.nix
            ./hosts/pannu
          ];
        };
        torni = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            { nixpkgs.config.allowUnfree = true; }
            ./hosts/common.nix
            ./hosts/torni
          ];
        };
      };
      devShells.x86_64-linux.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          helix
          nixfmt
          nixd
          packwiz
        ];
      };
    };
}
