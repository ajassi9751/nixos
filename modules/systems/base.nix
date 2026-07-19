{ self, inputs, ... }: {
  flake.nixosModules.base-system =
    { pkgs, pkgs-old, system-arch, swap-write-device, ... }:
    {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      # boot.loader.grub.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Latest kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Forcefully clear the hardware-generated swap devices
      swapDevices = pkgs.lib.mkForce [ ];

      # May not be the best for servers but I care about ssd life
      # Configure zram
      zramSwap = {
        enable = true;
        priority = 100; # Not relevant but gives it higher priority than regular swap
        algorithm = "lz4"; # lz4 algorithm is lighter but compresses less than zstd
        memoryPercent = 50; # Can use up to 50% of memory to compress
        writebackDevice = swap-write-device; # Uses this partition in case there is too much data
      };

      # I also don't know if this is good for servers
      # Userspace oom killer which helps with zram
      systemd.oomd.enable = true;

      # Keeps ssds healthy, its already enabled by default but this is to make it sure and explicit
      services.fstrim.enable = true;

      # Ssd health stuff and helps with power as it gives info to tlp
      services.smartd.enable = true;

      # Maybe change this
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

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
        };
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      security.rtkit.enable = true;

      # May want to change for servers
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.aikam = {
        # shell = "${pkgs.zsh}/bin/zsh";
        isNormalUser = true;
        description = "Aikam";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = with pkgs; [
          #  thunderbird
        ];
      };

      users.users.harnoor = {
        isNormalUser = true;
        description = "Harnoors account for lab";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
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

      # Maybe make this a separate config
      programs.neovim = {
        package = inputs.nixpkgs-unstable.legacyPackages.${system-arch}.neovim-unwrapped;
        defaultEditor = true;
        enable = true;
      };

      # Should make this a separate config
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
              insteadOf = [
                "github:"
                "gh:"
              ];
            };
            "git@github.com:" = {
              insteadOf = [
                "ggithub:"
                "ggh:"
              ];
            };
          };
          alias = {
            cm = "commit -am";
          };

        };
      };

      services.tailscale.enable = true;

      # Maybe use pkgs for this
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        vim
        curl
        # wget
        # yazi # Put this here and make it unstable
        fastfetch
        zsh
        gh
        cowsay
        btop
        wl-clipboard
        ripgrep
        fzf
        # fish
        # tmux
        gnumake
        p7zip
        zip
        unzip
        # Maybe remove zoxide
        zoxide
        pciutils
        ffmpeg
        pkgs-old.neofetch
        self.packages.${system-arch}.update-utils
      ];

      fonts.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];
    };
}
