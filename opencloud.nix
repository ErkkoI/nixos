{ pkgs, ... }:
let
  secretsFile = "/var/lib/secrets/opencloud.env";
in
{
  services.caddy = {
    virtualHosts."cloud.erkkoihalainen.fi".extraConfig = ''
      reverse_proxy 127.0.0.1:9200
    '';
  };

  services.opencloud = {
    enable = true;
    url = "https://cloud.erkkoihalainen.fi";
    address = "127.0.0.1";
    environmentFile = secretsFile;
    environment = {
      # The NixOS fullstack module uses internally generated certificates.
      OC_INSECURE = "true";
      # Caddy terminates public TLS; its public OIDC certificate is validated.
      # PROXY_TLS = "false";
      IDM_CREATE_DEMO_USERS = "false";
    };
  };

  # Generate an initial admin password on the VPS at first boot. No password
  # enters the repository, Nix store, shell arguments, or this playbook.
  systemd.services.opencloud-bootstrap-secrets = {
    description = "Create the initial OpenCloud admin credential";
    before = [
      "opencloud-init-config.service"
      "opencloud.service"
    ];
    requiredBy = [
      "opencloud-init-config.service"
      "opencloud.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    script = ''
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

  systemd.services.opencloud = {
    requires = [ "opencloud-init-config.service" ];
    after = [ "opencloud-init-config.service" ];
  };
}
