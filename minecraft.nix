{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.firewall.allowedTCPPorts = [ 25565 ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = false;
    servers.joulupojat = {
      enable = true;
      autoStart = false;
      package = pkgs.fabricServers.fabric-1_21_11.override {
        loaderVersion = "0.18.4";
        # jre_headless = pkgs.jre25_minimal;
        jre_headless = pkgs.graalvmPackages.graalvm-ce;
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
      jvmOpts = "-Xmx2G -Xms1G";
      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Cloth-Config = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9s6osm5g/versions/xuX40TN5/cloth-config-21.11.153-fabric.jar"; sha512 = "8f455489d4b71069e998568cf4e1450116f4360a4eb481cd89117f629c6883164886cf63ca08ac4fc929dd13d1112152755a6216d4a1498ee6406ef102093e51"; };
            Clumps = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/OgBE8Rz4/Clumps-fabric-1.21.11-29.0.0.1.jar"; sha512 = "3cff3cd2d600a6d84030b38ce6244143d13774d5287627bb7312adae5edc7ae2d9151a2c9c39a00681c354d549b0a62ac48c0077ba586cc10c00d32f39e87f18"; };
            Common-Network = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/HIuqnQpi/versions/XcmNR0QN/common-networking-fabric-1.0.22-1.21.11.jar"; sha512 = "11fdd4ebfb133866fb09e7f2314d9e1be34ea2ffee4d9a687276391f44733242ca5684704e00a310d81b94d534327f0ea592386705835b653c1339335022e306"; };
            Distant-Horizons = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uCdwusMi/versions/GT3Bm3GN/DistantHorizons-2.4.5-b-1.21.11-fabric-neoforge.jar"; sha512 = "a9f673fac1f6f554b7394168cbe726f1a15eb2bbef1b65b3c9979853af8de70bf13a457c88ebdc30b955a071d519e86c631cdbf1dd39cdab7c73b9c2d7f165e1"; };
            Fabric-API = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/gB6TkYEJ/fabric-api-0.140.2%2B1.21.11.jar"; sha512 = "af4465797d80401021a6aefc8c547200e7c0f8cae134299bf3fafbc310fa81f055246b0614fc0e037538f4a844e55aad30abfa3c67460422853dfc426f086d00"; };
            Ferrite-Core = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/eRLwt73x/ferritecore-8.0.3-fabric.jar"; sha512 = "be600543e499b59286f9409f46497570adc51939ae63eaa12ac29e6778da27d8c7c6cd0b3340d8bcca1cc99ce61779b1a8f52b990f9e4e9a93aa9c6482905231"; };
            Inventory-Sorting = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/5ibSyLAz/versions/Dq4h9aTH/inventorysorter-fabric-2.1.4%2Bmc1.21.11.jar"; sha512 = "a3ea975d76a7073f98eb5ccb47360e48e4ce2eab44b32b1ec720ce870f0e296958f17ecb7c13a3397671d637cc92e022e7b6e978e4cd30a2ee64b09d308358c5"; };
            JEI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/9i2DXscL/jei-1.21.11-fabric-27.3.0.14.jar"; sha512 = "b9af1ab742e436914522579533a0fa190b61059bee221eebb7c192b98d262a330827e749af91b4c082aa727b13f28070910be55ae8ad7d6033fdc9ccd6668cf4"; };
            Journey-Map = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/lfHFW1mp/versions/SaQABb8q/journeymap-fabric-1.21.11-6.0.0-beta.54.jar"; sha512 = "9a9a4d68087124061efe0101825964256384fbe1803932a115305c063cc45d7a9db4a8fb73cb862b8cf1ab26b65e554d2ff70307e3d1f2211b3173bb3f07f255"; };
            Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/gl30uZvp/lithium-fabric-0.21.2%2Bmc1.21.11.jar"; sha512 = "94625510013e0daaf1c2e2b6d8a463c932ff6220f91ba5b0cd5f868658215f046d94d07b3465660f576c4dc27a5aa183dfbdc1c9303f11894b5b25a1dc6c3bb6"; };
            Spark = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/l6YH9Als/versions/1CB3cS0m/spark-1.10.156-fabric.jar"; sha512 = "c17995968561761e0857445e28e9235f3c0ec5fc0695deda3b2ae408baf074348822f0a8671791032b32c6b2977edba1024a2cc3b4588b9274e7f131795af6e0"; };
          }
        );
      };
    };
  };
}
