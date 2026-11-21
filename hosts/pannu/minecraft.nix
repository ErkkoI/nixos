{
  config,
  pkgs,
  lib,
  ...
}:
let
  minecraft_jre = pkgs.jre25_minimal.override {
    modules = [
      "java.base"
      "java.desktop"
      "java.management"
      "java.xml"
      "java.logging"
      "java.sql"
      "java.compiler"
      "java.net.http"
      "jdk.jfr"
      "jdk.zipfs"
      "jdk.unsupported"
      "jdk.management"
    ];
    jdk = pkgs.jdk25_headless;
  };
  modpack = pkgs.callPackage ../../pkgs/modpack { };
  mcVersion = modpack.pack.versions.minecraft;
  fabricVersion = modpack.pack.versions.fabric;
  serverVersion = lib.replaceString "." "_" "fabric-${mcVersion}";
  serverPort = 25565;

  minecraftServices = lib.mapAttrsToList (name: _: "minecraft-server-${name}.service") (
    lib.filterAttrs (_: server: server.enable) config.services.minecraft-servers.servers
  );

  ensureMinecraftStopped = pkgs.writeShellScript "ensure-minecraft-stopped" ''
    set -euo pipefail
    for unit in ${lib.escapeShellArgs minecraftServices}; do
      state="$(${config.systemd.package}/bin/systemctl is-active "$unit" || true)"
      case "$state" in
        inactive|failed) ;;
        *)
          echo "Skipping: $unit is $state"
          exit 1
          ;;
      esac
    done
  '';

  cancelRebootIfMinecraftRunning = pkgs.writeShellScript "cancel-reboot-if-minecraft-running" ''
    set -euo pipefail
    if ! ${ensureMinecraftStopped}; then
      echo "Cancelling scheduled reboot because a Minecraft server is running"
      ${config.systemd.package}/bin/shutdown -c || true
    fi
  '';
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.joulupojat = {
      enable = true;
      autoStart = false;
      package = pkgs.minecraftServers.${serverVersion}.override {
        loaderVersion = fabricVersion;
        jre_headless = minecraft_jre;
      };
      whitelist = {
        ukimies = "f5e5eb08-eb21-40a0-8b62-486f4b6f8559";
        Lanttu27 = "42b25794-851f-45a4-9366-f3aed5483f00";
        SmurffiLauta = "12a61556-e02f-44c8-9ac7-ae99ae25c067";
        cakeman96 = "56e4d186-3df8-40ca-b579-8332176d2234";
      };
      operators = {
        ukimies = "f5e5eb08-eb21-40a0-8b62-486f4b6f8559";
        cakeman96 = "56e4d186-3df8-40ca-b579-8332176d2234";
      };
      serverProperties = {
        white-list = true;
        enforce-whitelist = true;
        online-mode = true;
        server-port = serverPort;
        enable-rcon = false;
        enable-query = false;
      };
      jvmOpts = "-Xmx2560M -Xms1024M -XX:+UseZGC -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem";
      symlinks.mods = "${modpack}/mods";
    };
  };

  # Skip automatic upgrades and reboots while a Minecraft server is running,
  # and further restrict filesystem and privilege access for the server unit.
  systemd.services = {
    minecraft-server-joulupojat.serviceConfig = {
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ config.services.minecraft-servers.dataDir ];
    };
    nixos-upgrade.serviceConfig = {
      ExecCondition = [ "${ensureMinecraftStopped}" ];
      ExecStartPost = [ "${cancelRebootIfMinecraftRunning}" ];
    };
  };
}
