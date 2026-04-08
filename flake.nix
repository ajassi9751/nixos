{
  description = "System flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    # Old version of nixpgks for neofetch
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, nixpkgs-old, hyprland } @ inputs:
  let
    pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; };
    pkgs-stable = import nixpkgs-stable { system = "x86_64-linux"; };
    pkgs-old = import nixpkgs-old { system = "x86_64-linux"; };
    # etcherPkg = pkgs-unstable.callPackage ./etcher.nix { };
  in
  {
	nixosConfigurations.system = nixpkgs-unstable.lib.nixosSystem {
		specialArgs = { inherit inputs; };
		modules = [
			./configuration.nix
			{
  				environment.systemPackages = with pkgs-unstable; [
					ghostty
					yazi
					foot
					pkgs-old.neofetch
					# etcherPkg
				];
			}
		];
	};
  };
}
