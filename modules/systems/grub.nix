{ ... }:
{
  flake.nixosModules.grub-system =
    { pkgs, boot-loader-device, ... }:
    {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = boot-loader-device;
    };
}
