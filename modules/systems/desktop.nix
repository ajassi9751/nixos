{ inputs, ... }: {
  flake.nixosModules.desktop-system =
  { pkgs, pkgs-unstable, system-arch, ... }: {
      # boot.kernelModules = [ "bfq" ]; # Load bfq kernel module

      boot.kernel.sysctl = {
        "vm.swappiness" = 10; # Keep program memory out of swap and prefer it over filesystem cache (better for pc's). default: 60
        "vm.vfs_cache_pressure" = 50; # Keep filesystem metadata in memory. default: 100
        "vm.dirty_ratio" = 10; # Flush dirty pages more often to help against crashes and pauses in io. default: 20
        "vm.dirty_background_ratio" = 5; # Controls when background flushing starts. default: ?
      };


      # Enable the X11 windowing system.
      services.xserver.enable = true;

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable the KDE Desktop Environment and the login manager
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      programs.firefox.enable = true;
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = inputs.nixpkgs-unstable.legacyPackages.${system-arch}.hyprland;
        portalPackage = inputs.nixpkgs-unstable.legacyPackages.${system-arch}.xdg-desktop-portal-hyprland;
      };

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
      };

      programs.gamemode.enable = true;

      programs.kdeconnect.enable = true;

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/home/.steam/root/compatabilitytools.d"; # Used for protonup
      };

      environment.systemPackages = with pkgs; [
        rofi
        quickshell
        cava
        hypridle
        hyprlock
        # stylua
        # popsicle
        # cmake
        # ghostty # Make this unstable
        # localsend
        brave
        # chromium
        playerctl
        brightnessctl
        pavucontrol
        qemu
        # gdb
        mangohud
        protonup-ng
        # ckan
        # lutris # Will use if needed
        # heroic # Also will use if needed
        # bottles # Same as the other two
        vlc
        # zig
        prismlauncher
        obs-studio
        # Most likley get rid of these
        inputs.frc-nix.packages.${system-arch}.vscode-wpilib
        inputs.frc-nix.packages.${system-arch}.advantagescope
        inputs.frc-nix.packages.${system-arch}.choreo
        inputs.frc-nix.packages.${system-arch}.pathplanner
        inputs.frc-nix.packages.${system-arch}.elastic-dashboard
        # inputs.frc-nix.packages.${system-arch}.sysid
        # Dev tools
        pkgs-unstable.clang-tools
        pkgs-unstable.rust-analyzer
        pkgs-unstable.rustfmt
        pkgs-unstable.cargo
        pkgs-unstable.rustc
        pkgs-unstable.gcc
        pkgs-unstable.clang
        # Terminals
        pkgs-unstable.ghostty
        pkgs-unstable.foot
      ];
  };
}
