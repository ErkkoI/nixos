{ pkgs, ... }:
let
  privateKeyFile = "/var/lib/secrets/wireguard-wg0.key";
  publicKeyFile = "/var/lib/secrets/wireguard-wg0.pub";
  listenPort = 51820;
in
{
  # Forward only explicitly allowed peer-to-peer traffic (iPhone -> torni t3code)
  # over WireGuard, dropping all other forwarded packets via nftables.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nftables.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ listenPort ];
    filterForward = true;
    extraForwardRules = ''
      iifname "wg0" oifname "wg0" ip saddr 10.100.0.3 ip daddr 10.100.0.2 tcp dport 3773 accept
    '';
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      inherit listenPort privateKeyFile;
      peers = [
        # Add each peer's public key after bootstrapping, then rebuild pannu.
        {
          name = "torni";
          publicKey = "B09fJo5U1Bcead+4gDtha8eHwuA30Mz//Wktblv4BxQ=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          name = "iphone";
          publicKey = "P/iCtwuTjQenIZ9xvDh9HCC6HV/V8dZwfVHhiFrf23M=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };

  # Generate the WireGuard keypair on first activation so no private key enters
  # the repository or Nix store.
  systemd.services.wireguard-bootstrap-key = {
    description = "Generate the WireGuard keypair for wg0";
    before = [ "wireguard-wg0.service" ];
    requiredBy = [ "wireguard-wg0.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    script = ''
      set -euo pipefail
      install -d -m 0700 /var/lib/secrets
      if [ ! -e ${privateKeyFile} ]; then
        key_file=$(mktemp /var/lib/secrets/.wireguard-wg0.XXXXXX)
        trap 'rm -f "$key_file"' EXIT
        ${pkgs.wireguard-tools}/bin/wg genkey > "$key_file"
        mv "$key_file" ${privateKeyFile}
      fi
      chmod 0600 ${privateKeyFile}
      ${pkgs.wireguard-tools}/bin/wg pubkey < ${privateKeyFile} > ${publicKeyFile}
      chmod 0644 ${publicKeyFile}
    '';
  };
}
