{ ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts."localhost".extraConfig = ''
      tls internal
      respond "Hello, world!"
    '';
  };
}
