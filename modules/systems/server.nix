{ self, ... }: {
  flake.nixosModules.server-system =
    { pkgs, system-arch, swap-write-device, ... }:
    {

      # bfq kernel module
      # boot.kernelModules = [ "bfq" ];

      services.udev.extraRules = ''
        # IO Scheduler config

        # HDDs use bfq for fairness and low latency
        ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

        # Sata SSDs use mq-deadline becuase they aren't smart enough for none and need a lighweight scheduler
        ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

        # NVMe SSDs use none because they are smart and fast
        ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"

        # Readahead config

        # Set read-ahead to 4096 sectors (2MB) for rotational drives (HDDs)
        ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="1", ATTR{queue/read_ahead_kb}="2048"

        # Keep a smaller read-ahead (or default) for non-rotational drives (SSDs/NVMe)
        ACTION=="add|change", KERNEL=="sd*[!0-9]|nvme*", ATTR{queue/rotational}=="0", ATTR{queue/read_ahead_kb}="512"

      '';

      # Configure zram
      zramSwap = {
        enable = true;
        priority = 100; # Not relevant but gives it higher priority than regular swap
        algorithm = "zstd"; # zstd may be better for the server
        memoryPercent = 50; # Can use up to 50% of memory to compress
        writebackDevice = swap-write-device; # Uses this partition in case there is too much data
      };


      boot.kernel.sysctl = {
        # High swappiness becuase of zram
        "vm.swappiness" = 140;

        # Helps keep filesystem metadata cached in RAM, 
        "vm.vfs_cache_pressure" = 50;

        # Increase maximum number of memory map areas (helpful for transcoding)
        "vm.max_map_count" = 262144;

        # Keep dirty page flushes frequent and small to prevent write stalls.
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;

        # Increase the maximum amount of queued connections to prevent dropped connections when multiple clients connect at once.
        "net.core.somaxconn" = 4096;

        # Increase TCP read/write buffer limits for high-bitrate 4K streaming.
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.tcp_rmem" = "4096 87380 16777216";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      };

      services.headscale = {
        enable = true;
        port = 8080;

        settings = {
          # The publicly accessible URL where your clients will reach Headscale
          server_url = "https://colrec.ddns.me";

          # The port Headscale listens on internally
          listen_addr = "0.0.0.0:8080";

          # Tailscale IP prefix allocations for your VPN clients
          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];

          # DNS settings for connected nodes
          dns = {
            magic_dns = true;
            base_domain = "hs.net";
            nameservers.global = [
              "1.1.1.1"
              "9.9.9.9"
              "8.8.8.8"
            ];
          };
        };
      };
      services.caddy = {
        enable = true;
        virtualHosts."colrec.ddns.me".extraConfig = ''
          reverse_proxy localhost:8080
        '';
      };
      # Open HTTP (80) and HTTPS (443) ports for ACME certificates
      networking = {
        networkmanager.enable = false;
        firewall.allowedTCPPorts = [
          80
          443
          8096
          8920
          8020
          8040
        ];
        firewall.allowedUDPPorts = [ 41641 ]; # Tailscale direct communication port
        # Set DNS servers
        nameservers = [
          "1.1.1.1"
          "9.9.9.9"
          "8.8.8.8"
        ];
        # Set default gateway (my router's internal IP address)
        defaultGateway = "10.8.88.254";
        # Configure the interface with a static IP
        interfaces.enp3s0 = {
          ipv4.addresses = [
            {
              address = "10.8.88.10"; # Your chosen static IP
              prefixLength = 24; # Subnet mask 255.255.255.0 is /24
            }
          ];
        };
      };
      # services.nextcloud = {
      #     enable = true;
      #     hostName = "aikamcloud";
      # };
      services.jellyfin.enable = true;
      # Auto backup
      services.btrbk.instances."prot-backup" = {
        onCalendar = "02:00";

        settings = {
          snapshot_preserve_min = "7d";
          snapshot_preserve = "4w";

          target_preserve_min = "7d";
          target_preserve = "4w 6m";

          volume."/int/prot" = {
            snapshot_dir = ".snapshots";

            subvolume."." = {
              target = "/mnt/backup/prot_backup";
            };
          };
        };
      };
      systemd.services.upload-service = {
        description = "Upload service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "aikam";
          Group = "users";

          ExecStart = "${
            self.packages.${system-arch}.upload-service
          }/bin/upload-service /int/prot/jellyfin/family-media";

          WorkingDirectory = "/etc/nixos/modules/packages/upload-service";

          # Hardening properties
          Restart = "on-failure";
          PrivateTmp = true;
        };
      };
    };
}
