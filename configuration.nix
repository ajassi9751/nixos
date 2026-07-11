# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, lib, pkgs, pkgs-unstable, system, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # SYSTEM TWEAKS

  # boot.kernelModules = [ "bfq" ]; # Load bfq kernel module

  # Relies on hardware!
  # Enable full tickless mode on cpus 1-3 (0 is left regular on purpose)
  # Kinda fishy tho
  boot.kernelParams = [
    "isolcpus=1-3"
    "nohz_full=1-3"
    "rcu_nocbs=1-3"
    # "elevator=bfq"
  ];

  # Forcefully clear the hardware-generated swap devices
  swapDevices = lib.mkForce [ ];

  # Configure zram
  zramSwap = {
    enable = true;
    priority = 100; # Not relevant but gives it higher priority than regular swap
    algorithm = "lz4"; # lz4 algorithm is lighter but compresses less than zstd
    memoryPercent = 50; # Can use up to 50% of memory to compress
    writebackDevice = "/dev/sda3"; # Uses this partition in case there is too much data
  };

  # Userspace oom killer which helps with zram
  systemd.oomd.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # Keep program memory out of swap and prefer it over filesystem cache (better for pc's). default: 60
    "vm.vfs_cache_pressure" = 50; # Keep filesystem metadata in memory. default: 100
    "vm.dirty_ratio" = 10; # Flush dirty pages more often to help against crashes and pauses in io. default: 20
    "vm.dirty_background_ratio" = 5; # Controls when background flushing starts. default: ?
  };

  #  specialisation = {
  #    lts-kernel.configuration = {
  # boot.kernelPackages = pkgs.linuxPackages;	
  #    };
  #  };

  # DEFAULT STUFF

  networking.hostName = "aikamnix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.aikam = {
    # shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    description = "Aikam";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  users.users.harnoor = {
    isNormalUser = true;
    description = "Harnoors account for lab";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # STUFF I INSTALLED

  # Enable the KDE Desktop Environment and the login manager
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.appimage.enable = true;
  programs.firefox.enable = true;
  programs.hyprland = {
  	enable = true;
  	xwayland.enable = true;
	package = pkgs-unstable.legacyPackages.${system}.hyprland;
	portalPackage = pkgs-unstable.legacyPackages.${system}.xdg-desktop-portal-hyprland;
  };
  programs.neovim = {
      package = pkgs-unstable.legacyPackages.${system}.neovim-unwrapped;
      defaultEditor = true;
      enable = true;
  };

  programs.git = {
  	enable = true;
	# package = pkgs.gitFull;
	config = {
		user.name = "Aikam Jassi";
		user.email = "ajassi9751@gmail.com";
		init.defaultBranch = "main";
		safe.directory = "/etc/nixos";
		credential.helper = "libsecret";
		# credential.helper = "${pkgs.libsecret}/bin/secret-tool";
		# credential.helper = "${pkgs.gitFull}/libexec/git-core/git-credential-libsecret";
		# credential.helper = "cache";
		url = {
			"https://github.com/" = {
				insteadOf = [ "github:" "gh:" ];
			};
			"git@github.com:" = {
				insteadOf = [ "ggithub:" "ggh:" ];
			};
		};
		alias = {
			cm = "commit -am";
		};

	};
  };

  programs.steam = {
  	enable = true;
	gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.kdeconnect.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vim
    wget
    # ghostty
    # yazi
    rofi
    quickshell
    cava
    fastfetch
    hypridle
    hyprlock
    zsh
    gh
    cowsay
    btop
    wl-clipboard
    ripgrep
    fzf
    fish
    stylua
    clang-tools
    rust-analyzer
    rustfmt
    tmux
    popsicle
    cmake
    gnumake
    p7zip
    zip
    unzip
    zoxide
    pciutils
    localsend
    brave
    # chromium
    playerctl
    brightnessctl
    ffmpeg
    pavucontrol
    qemu
    gdb
    mangohud
    protonup-ng
    ckan
    # lutris # Will use if needed
    # heroic # Also will use if needed
    # bottles # Same as the other two
    vlc
    # zig
    prismlauncher
  ];

  environment.sessionVariables = {
  	STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/home/.steam/root/compatabilitytools.d"; # Used for protonup
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # THE MAGIC NUMBER

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
