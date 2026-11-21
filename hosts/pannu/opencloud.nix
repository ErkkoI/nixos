{ pkgs, ... }:
let
  secretsFile = "/var/lib/secrets/opencloud.env";
in
{
  services.caddy = {
    virtualHosts."cloud.erkkoihalainen.fi".extraConfig = ''
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:9200
    '';
  };

  services.opencloud = {
    enable = true;
    port = 9200;
    url = "https://cloud.erkkoihalainen.fi";
    address = "127.0.0.1";
    environment = {
      PROXY_TLS = "false";
      IDM_CREATE_DEMO_USERS = "false";
    };
  };

  # Generate an initial admin password on the VPS at first boot. No password
  # enters the repository, Nix store, shell arguments, or this playbook.
  systemd.services.opencloud-bootstrap-secrets = {
    description = "Create the initial OpenCloud admin credential";
    before = [ "opencloud-init-config.service" ];
    requiredBy = [ "opencloud-init-config.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    script = ''
      set -euo pipefail
      install -d -m 0700 /var/lib/secrets
      if [ ! -e ${secretsFile} ]; then
        credential_file=$(mktemp /var/lib/secrets/.opencloud.XXXXXX)
        trap 'rm -f "$credential_file"' EXIT
        printf 'ADMIN_PASSWORD=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 24)" > "$credential_file"
        mv "$credential_file" ${secretsFile}
      fi
      chmod 0600 ${secretsFile}
    '';
  };

  # Pass ADMIN_PASSWORD only to the one-shot provisioning unit so it does not
  # remain in the long-running opencloud daemon's environment.
  systemd.services.opencloud-init-config.serviceConfig.EnvironmentFile = [ secretsFile ];

  systemd.services.opencloud = {
    requires = [ "opencloud-init-config.service" ];
    after = [ "opencloud-init-config.service" ];
  };
}
