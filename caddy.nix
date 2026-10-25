{ ... }:
{
  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts."erkkoihalainen.fi".extraConfig = ''
      tls internal
      respond "Hello!"
    '';
  };
}
