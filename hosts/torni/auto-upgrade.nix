{ pkgs, ... }:
let
  notifyUpgrade = pkgs.writeShellApplication {
    name = "nixos-upgrade-notify";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
      pkgs.util-linux
    ];
    text = ''
      booted="$(readlink -f /run/booted-system)"
      current="$(readlink -f /run/current-system)"
      staged="$(readlink -f /nix/var/nix/profiles/system)"

      if [ "$staged" = "$booted" ] || [ "$staged" = "$current" ]; then
        exit 0
      fi

      state_file="/run/nixos-upgrade-last-notified"
      if [ -f "$state_file" ] && [ "$(cat "$state_file")" = "$staged" ]; then
        exit 0
      fi

      uid="$(id -u erkkoi)"
      bus="/run/user/$uid/bus"
      if [ ! -S "$bus" ]; then
        exit 0
      fi

      if runuser -u erkkoi -- \
        env DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
        XDG_RUNTIME_DIR="/run/user/$uid" \
        notify-send \
        --app-name="NixOS Auto-Upgrade" \
        --icon=system-software-update \
        "NixOS update ready" \
        "A new system generation is staged and will be applied on your next reboot."; then
        printf '%s\n' "$staged" > "$state_file"
      fi
    '';
  };
in
{
  system.autoUpgrade = {
    enable = true;
    # Disable adding the --upgrade flag. Not used with flakes.
    # Flake update is done in a GH action.
    upgrade = false;
    flake = "github:erkkoi/nixos#torni";
    operation = "boot";
    dates = "daily";
    persistent = true;
    randomizedDelaySec = "15min";
    allowReboot = false;
  };

  systemd.services.nixos-upgrade.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
    ExecStartPost = [ "-${notifyUpgrade}/bin/nixos-upgrade-notify" ];
  };
}
