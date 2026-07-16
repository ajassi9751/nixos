{
  description = "System flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # nixpkgs-super-unstable = "github:nixos/nixpkgs"; # Most bleeding edge packages before they are even built by hydra so it forces constant recompilation
    # Old version of nixpgks for neofetch
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";
    # Frc-nix input for frc stuff
    frc-nix.url = "github:frc4451/frc-nix";
    # Nix neovim config tool
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, nixpkgs-old, frc-nix, nvf} @ inputs:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
    pkgs-stable = import nixpkgs-stable { inherit system; };
    pkgs-old = import nixpkgs-old { inherit system; };
  in
  {
	# Make sure that configuration.nix gets the stable packages
	nixosConfigurations.system = nixpkgs-stable.lib.nixosSystem {
		specialArgs = { inherit inputs system; pkgs-unstable = nixpkgs-unstable; };
		modules = [
			./configuration.nix
			{
				# Nix packages from other versions
  				environment.systemPackages = with pkgs-unstable; [
					ghostty
					yazi
					foot
					awww
					pkgs-old.neofetch
					cargo
					rustc
					gcc
					clang

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
			nvf.nixosModules.default
			{
				# NVF config
				programs.nvf = {
					enable = true;
					settings = {
						vim = {	
                                                        theme = {
                                                                enable = true;
                                                                name = "gruvbox";
                                                                style = "dark";
                                                                # Hopefully doesn't conflict and instead compliments terminal transparency
                                                                transparent = true;
                                                        };
							vimAlias = false;
							lsp.enable = true;
							telescope.enable = true;
							autocomplete.nvim-cmp.enable = true;
                                                        utility.oil-nvim.enable = true;
                                                        utility.motion.flash-nvim.enable = true;
                                                        git.gitsigns.enable = true;
							languages = {
								enableTreesitter = true;

								rust.enable = true;
								nix.enable = true;
								clang.enable = true;
								lua.enable = true;
                                                                make.enable = true;
                                                                cmake.enable = true;
							};
						};	
					};
				};
			}
		];
	};
  };
}
