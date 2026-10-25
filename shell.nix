let
  nixpkgs = fetchTarball "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    helix
    nixfmt
    nixd
  ];
}
