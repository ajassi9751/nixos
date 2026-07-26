{ ... }: {
  flake.nixosModules.server-system = { pkgs, ... }: {
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
      firewall.allowedTCPPorts = [ 80 443 8096 8920 ];
      firewall.allowedUDPPorts = [ 41641 ]; # Tailscale direct communication port
      # Set DNS servers
      nameservers = [ "1.1.1.1" "9.9.9.9" "8.8.8.8" ];
      # Set default gateway (my router's internal IP address)
      defaultGateway = "10.8.88.254";
      # Configure the interface with a static IP
      interfaces.enp3s0 = {
        ipv4.addresses = [ {
          address = "10.8.88.10";  # Your chosen static IP
          prefixLength = 24;          # Subnet mask 255.255.255.0 is /24
        } ];
      };
    };
    # services.nextcloud = {
    #     enable = true;
    #     hostName = "aikamcloud";
    # };
    services.jellyfin.enable = true;
  };
}
