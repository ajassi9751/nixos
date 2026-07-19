{ self, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.hptop = inputs.nixpkgs.lib.nixosSystem {

    # We pass unstable channels directly via specialArgs to our modules
    specialArgs = {
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgs-old = import inputs.nixpkgs-old {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      inherit inputs system;
    };

    modules = [
      ./_hardware/hptop.nix
      # Pull definitions straight from self instead of relative file system paths!
      self.nixosModules.base-system
      self.nixosModules.nvf-config

      # Target machine-specific packages
      (
        {
          pkgs-unstable,
          pkgs-old,
          system,
          ...
        }:
        {
          environment.systemPackages = with pkgs-unstable; [
            ghostty
            yazi
            cargo
            rustc
            gcc
            clang
            pkgs-old.neofetch

            # Pulls your custom package defined in your packages module
            self.packages.${system}.update-utils
          ];
        }
      )
    ];
  };
}
