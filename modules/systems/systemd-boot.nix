{ ... }: {
  flake.nixosModules.systemd-boot-system = { pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
  };
}
