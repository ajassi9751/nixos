{
  description = "Dendritic System Flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # Nixpkgs-stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";
    frc-nix.url = "github:frc4451/frc-nix";

    # 1. Pull in import-tree and flake-parts
    import-tree.url = "github:denful/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # 2. Tell import-tree to read your entire modules directory recursively
      imports = [
        (import-tree ./modules)
      ];

      systems = [ "x86_64-linux" ];
    };
}
