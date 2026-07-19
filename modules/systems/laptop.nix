{ inputs, ... }: {
  flake.nixosModules.laptop-system = { pkgs, system-arch, ... }: {
    # Disable power profiles daemon as tlp is better on older laptops (It also may be worse for window managers)
    services.power-profiles-daemon.enable = false;

    # Maybe make this a separate config
    services.tlp = {
      enable = true;
      settings = {
        # Enable the Radio Device Wizard
        BAY_POWEROFF_ON_AC = 0;
        BAY_POWEROFF_ON_BAT = 1;

        # Leave NFC alone
        RDW_EXCLUDE_NFC = 1;

        # No wifi with ethernet
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";

        # Stops connecting to cellular data on wifi
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "wwan";
      };
    };

  };
}
