{
  config,
  pkgs,
  lib,
  ...
}:
let
  minecraft_jre = pkgs.jre_minimal.override {
    modules = [
      "java.base"
      "java.desktop"
      "java.management"
      "java.xml"
      "jdk.jfr"
    ];
    jdk = pkgs.jdk_headless;
  };
  pack_path = ./modpack;
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/ErkkoI/nixos/raw/main/modpack/pack.toml";
    packHash = "0bjsxdbx6lqlndn6ihwk7mv7bvlk5qf2d7jk2wyncr9gwjrpkyyn";
    manifestHash = "0bjsxdbx6lqlndn6ihwk7mv7bvlk5qf2d7jk2wyncr9gwjrpkyyn";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = false;
    servers.joulupojat = {
      enable = true;
      autoStart = false;
      package = pkgs.fabricServers.${serverVersion}.override {
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
        server-port = 25565;
        enable-rcon = false;
        enable-query = false;
      };
      jvmOpts = "-Xmx2560M -Xms2560M -XX:+UseZGC -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem";
      symlinks = {
        "mods" = "${modpack}/mods";
      };
    };
  };
}
