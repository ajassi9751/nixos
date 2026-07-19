{ inputs, ... }: {
  flake.nixosModules.server-system = { pkgs, ... }: {
    services.headscale.enable = true;
    services.nextcloud.enable = true;
    services.jellyfin.enable = true;
  };
}
