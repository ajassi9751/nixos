{ self, inputs, ... }:
let
  system-arch = "x86_64-linux";
  swap-write-device = "/dev/disk/by-partuuid/eaf81a1b-239f-48a3-a45d-4fbbf492f28b";
  hostname = "hptop";
  boot-loader-device = "/dev/sda"; # Uses a /dev/sdX because it doesn't matter
in
{
  flake.nixosConfigurations.hptop = inputs.nixpkgs.lib.nixosSystem {

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
      ./_hardware/hptop.nix
      self.nixosModules.base-system
      self.nixosModules.desktop-system
      self.nixosModules.old-laptop-system
      self.nixosModules.systemd-boot-system
      ({ pkgs, ... }: {
        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "25.11"; # Did you read the comment?
      })
    ];
  };
}
