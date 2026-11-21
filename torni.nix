{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./disk-config-torni.nix
    ./hardware-configuration-torni.nix
    ./wireguard-torni.nix
  ];
  time.timeZone = "Europe/Helsinki";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [
      "fi_FI.UTF-8/UTF-8"
    ];
  };
  i18n.extraLocaleSettings = {
    LC_CTYPE = "en_US.UTF-8";
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
    LC_COLLATE = "fi_FI.UTF-8";
  };
  services.xserver.xkb = {
    layout = "fi";
  };
  console.keyMap = "fi";
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    powerManagement.enable = true;
    branch = "legacy_580";
  };
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };
  networking = {
    hostName = "torni";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    connect-timeout = 5;
    extra-substituters = [
      "ssh-ng://nix-cache@erkkoihalainen.fi?priority=50&ssh-key=/var/lib/secrets/nix-cache-ssh-key"
    ];
    extra-trusted-public-keys = [
      "pannu-1:QRqJH6Lc3N7PgltVmxkC7D5api3rdsJW85NWs4aidIY="
    ];
  };
  programs.ssh.knownHosts."erkkoihalainen.fi".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm93qernemJYeypgIbqxVzYY2ki9FH57L2rL2K5qa6L";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
  programs.steam.enable = true;
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "privacy.resistFingerprinting" = true;
    };
    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Feature Disabling
      DisableBuiltinPDFViewer = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;

      # Access Restrictions
      BlockAboutConfig = false;
      BlockAboutProfiles = true;

      # UI and Behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
          };
          "jid1-BoFifL9Vbdl2zQ@jetpack" = {
            install_url = moz "decentraleyes";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = moz "privacy-badger17";
            installation_mode = "force_installed";
          };
          "keepassxc-browser@keepassxc.org" = {
            install_url = moz "keepassxc-browser";
            installation_mode = "force_installed";
          };
        };

      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = {
            uiTheme = "dark";
            uiAccentCustom = true;
            uiAccentCustom0 = "#8300ff";
            cloudStorageEnabled = lib.mkForce false;
          };
        };
      };
    };
  };
  users.users.erkkoi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      plasma-login-manager.enable = true;
      autoLogin.user = "erkkoi";
    };
  };
  systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
  security.pam.services.plasmalogin-autologin.rules.auth = {
    systemd_loadkey = {
      order = 0;
      control = "optional";
      modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
    };
    plasmalogin = {
      order = 1;
      control = "include";
      modulePath = "plasmalogin";
    };
  };
  programs.git = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    keepassxc
    opencloud-desktop
    btop
    fastfetch
    github-cli
    helix
    musescore
    (callPackage ./t3code-nightly { enableAntigravity = true; })
  ];
  system.stateVersion = "26.05";
}
