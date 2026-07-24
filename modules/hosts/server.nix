{ self, inputs, ... }:
let
  system-arch = "x86_64-linux";
  swap-write-device = "/dev/sda3";
  hostname = "server";
  boot-loader-device = "/dev/sda";
in
{
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {

    specialArgs = {
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system-arch};
      inherit
        inputs
        system-arch
        swap-write-device
        hostname
        boot-loader-device
        ;
    };

    # This is kind of like composition
    modules = [
      ./_hardware/server.nix # Update this
      self.nixosModules.base-system
      self.nixosModules.server-system
      self.nixosModules.grub-system
      ({ pkgs, ... }: {
        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "26.05"; # Did you read the comment?
      })
    ];
  };
}
