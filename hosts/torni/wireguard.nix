{ pkgs, ... }:
let
  privateKeyFile = "/var/lib/secrets/wireguard-wg0.key";
  publicKeyFile = "/var/lib/secrets/wireguard-wg0.pub";
in
{
  # Keep NetworkManager from taking over the NixOS-managed WireGuard interface.
  networking.networkmanager.unmanaged = [ "interface-name:wg0" ];

  # Allow t3code (port 3773) over WireGuard strictly from the iPhone peer so
  # pannu cannot initiate connections to torni.
  networking.nftables.enable = true;
  networking.firewall.extraInputRules = ''
    iifname "wg0" ip saddr 10.100.0.3 tcp dport 3773 accept
  '';

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "10.100.0.2/24" ];
      inherit privateKeyFile;
      peers = [
        # Uncomment and fill in pannu's public key after bootstrapping pannu,
        # then rebuild torni.
        {
          name = "pannu";
          publicKey = "2WcN9V0RRjvSKVnRyMSgY/7+LaYPYBQc9rIt0flwwkk=";
          endpoint = "erkkoihalainen.fi:51820";
          allowedIPs = [ "10.100.0.0/24" ];
          # Keep the NAT mapping alive so peers (like iOS) can initiate
          # connections to torni through pannu.
          persistentKeepalive = 25;
          # Re-resolve erkkoihalainen.fi periodically and retry quickly at boot
          # if Wi-Fi/DNS comes up after wireguard-wg0.service.
          dynamicEndpointRefreshSeconds = 60;
          dynamicEndpointRefreshRestartSeconds = 5;
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
