{ ... }:
{
  services.caddy = {
    enable = true;
    openFirewall = true;
    email = "business@erkkoihalainen.fi";
    virtualHosts = {
      "erkkoihalainen.fi".extraConfig = ''
        header Strict-Transport-Security "max-age=31536000; includeSubDomains"
        respond "Hello!"
      '';
    };
  };
}
