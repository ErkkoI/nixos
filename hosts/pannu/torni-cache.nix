{
  config,
  pkgs,
  ...
}:
let
  secretKeyFile = "/var/lib/secrets/nix-cache-key.sec";
  publicKeyFile = "/var/lib/secrets/nix-cache-key.pub";
in
{
  nix.settings = {
    secret-key-files = [ secretKeyFile ];
    # Keep disk headroom on the 39 GiB VPS during builds.
    min-free = 3 * 1024 * 1024 * 1024;
    max-free = 6 * 1024 * 1024 * 1024;
  };

  systemd.services.nix-cache-bootstrap-key = {
    description = "Generate the Nix binary cache signing keypair";
    before = [ "nix-daemon.service" ];
    requiredBy = [ "nix-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    script = ''
      install -d -m 0700 /var/lib/secrets
      if [ ! -e ${secretKeyFile} ]; then
        ${config.nix.package}/bin/nix-store --generate-binary-cache-key \
          pannu-1 ${secretKeyFile} ${publicKeyFile}
        chmod 0600 ${secretKeyFile}
        chmod 0644 ${publicKeyFile}
      fi
    '';
  };

  # Dedicated unprivileged SSH account for torni's nix-daemon to substitute from
  # pannu's store over ssh-ng://, restricted strictly to nix-daemon --stdio.
  users.users.nix-cache = {
    isSystemUser = true;
    group = "nix-cache";
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      ''restrict,command="${config.nix.package}/bin/nix-daemon --stdio" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOJSKekRWFc9nNr68R5EYlmJvZtVE41tq1f+GIyiZkV torni-nix-cache''
    ];
  };
  users.groups.nix-cache = { };

  services.openssh.settings.AllowUsers = [ "nix-cache" ];

  systemd.services.torni-cache-build = {
    description = "Pre-build uncached packages for torni";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    before = [ "nixos-upgrade.service" ];
    path = [ config.nix.package ];
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUWeight = 20;
      StateDirectory = "nix-cache";
    };
    script = ''
      set -euo pipefail

      # Build t3code-nightly and torni's nvidia driver package (all outputs).
      # --out-link creates GC roots so pannu's nix.gc keeps the latest build
      # alive until superseded by the next run.
      nix build --refresh \
        --max-jobs 1 --cores 2 \
        --out-link /var/lib/nix-cache/t3code-nightly \
        github:erkkoi/nixos#packages.x86_64-linux.t3code-nightly

      nix build \
        --max-jobs 1 --cores 2 \
        --out-link /var/lib/nix-cache/torni-nvidia \
        'github:erkkoi/nixos#nixosConfigurations.torni.config.hardware.nvidia.package^*'
    '';
  };

  systemd.timers.torni-cache-build = {
    description = "Daily pre-build of uncached packages for torni";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Runs at 01:30 UTC (after the 01:00 UTC flake update GH Action,
      # and before the 03:00 UTC system.autoUpgrade window).
      OnCalendar = "*-*-* 01:30:00";
      RandomizedDelaySec = "15min";
      Persistent = true;
    };
  };
}
