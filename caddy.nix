{ ... }:
{
  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts."erkkoihalainen.fi".extraConfig = ''
      respond "Hello!"
    '';
  };
}
