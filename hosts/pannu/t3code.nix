{
  lib,
  pkgsUnstable,
  ...
}:
let
  t3code = pkgsUnstable.callPackage ../../pkgs/t3code-nightly {
    enableAntigravity = true;
  };
  wgIp = "10.100.0.1";
  port = 3773;
in
{
  # Expose t3code strictly over the authenticated WireGuard interface.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ port ];

  environment.systemPackages = [ t3code ];

  systemd.services.t3code = {
    description = "T3 Code server";
    after = [
      "wireguard-wg0.service"
      "network-online.target"
    ];
    requires = [ "wireguard-wg0.service" ];
    wants = [ "network-online.target" ];
    environment = {
      HOME = "/home/erkkoi";
      PATH = lib.mkForce "/run/wrappers/bin:/run/current-system/sw/bin";
    };
    serviceConfig = {
      Type = "simple";
      User = "erkkoi";
      Group = "users";
      WorkingDirectory = "/home/erkkoi";
      ExecStart = "${lib.getExe' t3code "t3"} serve --host ${wgIp} --port ${toString port}";
      KillMode = "mixed";
      OOMPolicy = "continue";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
