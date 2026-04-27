{
  description = "System flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    # Old version of nixpgks for neofetch
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";
    hyprland.url = "github:hyprwm/Hyprland";
    # Frc-nix input for frc stuff
    frc-nix.url = "github:frc4451/frc-nix";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, nixpkgs-old, hyprland, frc-nix } @ inputs:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
    pkgs-stable = import nixpkgs-stable { inherit system; };
    pkgs-old = import nixpkgs-old { inherit system; };
  in
  {
	nixosConfigurations.system = nixpkgs-unstable.lib.nixosSystem {
		specialArgs = { inherit inputs; };
		modules = [
			./configuration.nix
			{
				# Nix packages from other versions
  				environment.systemPackages = with pkgs-unstable; [
					ghostty
					yazi
					foot
					pkgs-old.neofetch
					# etcherPkg
				];
			}
			{
				# Frc nix stuff
				environment.systemPackages = with frc-nix.packages.${system}; [
					vscode-wpilib
					advantagescope
					choreo
					pathplanner
					elastic-dashboard
					# sysid
				];
			}
			{
				# Custom stuff
				environment.systemPackages = [
					(pkgs-unstable.callPackage ./update-utils.nix {})
				];
			}
		];
	};
  };
}
