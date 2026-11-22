{
  config,
  lib,
  pkgs,
  ...
}:
let
  launcher = pkgs.writeShellApplication {
    name = "t3code-nightly";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      gnused
      jq
      libnotify
      openssl
    ];
    text = ''
      data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/t3code-nightly"
      appimage="$data_dir/T3-Code-Nightly-x86_64.AppImage"

      if [ ! -x "$appimage" ] || [ "''${T3CODE_FORCE_DOWNLOAD:-0}" = "1" ]; then
        mkdir -p "$data_dir"
        notify() {
          notify-send --app-name="T3 Code (Nightly)" "$1" "$2" 2>/dev/null || true
        }

        release_json=$(curl -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases?per_page=20")
        tag=$(jq -er '
          [ .[]
            | select((.draft | not) and .prerelease and (.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+-nightly\\.[0-9]{8}\\.[0-9]+$")))
            | select(.assets | any(.name == "T3-Code-Nightly-x86_64.AppImage"))
          ][0].tag_name
        ' <<< "$release_json")

        asset_url=$(jq -er --arg tag "$tag" '
          .[] | select(.tag_name == $tag)
          | .assets[] | select(.name == "T3-Code-Nightly-x86_64.AppImage")
          | .browser_download_url
        ' <<< "$release_json")

        yml_url=$(jq -r --arg tag "$tag" '
          .[] | select(.tag_name == $tag)
          | .assets[] | select(.name == "nightly-linux.yml")
          | .browser_download_url
        ' <<< "$release_json")

        notify "Downloading T3 Code (Nightly)" "Fetching $tag..."
        echo "Downloading T3 Code (Nightly) $tag..." >&2

        tmp=$(mktemp "$data_dir/.T3-Code-Nightly.XXXXXX.AppImage")
        trap 'rm -f "$tmp"' EXIT

        curl -fL --progress-bar -o "$tmp" "$asset_url"

        if [ -n "$yml_url" ]; then
          expected_sha512=$(curl -fsSL "$yml_url" | sed -n 's/^sha512:[[:space:]]*//p' | tail -n1 | tr -d '\r')
          if [ -n "$expected_sha512" ]; then
            actual_sha512=$(openssl dgst -sha512 -binary "$tmp" | base64 -w0)
            if [ "$actual_sha512" != "$expected_sha512" ]; then
              notify "T3 Code (Nightly) download failed" "SHA-512 checksum mismatch for $tag"
              echo "SHA-512 mismatch for $tag: expected $expected_sha512, got $actual_sha512" >&2
              exit 1
            fi
          fi
        fi

        chmod +x "$tmp"
        mv -f "$tmp" "$appimage"
        trap - EXIT
      fi

      export T3CODE_CLOUDFLARED_PATH="''${T3CODE_CLOUDFLARED_PATH:-${lib.getExe pkgs.cloudflared}}"
      exec ${lib.getExe config.programs.appimage.package} "$appimage" "$@"
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "t3code-nightly";
    desktopName = "T3 Code (Nightly)";
    comment = "Minimal web GUI for coding agents";
    exec = "t3code-nightly %U";
    terminal = false;
    icon = "t3code-nightly";
    startupWMClass = "t3code";
    categories = [ "Development" ];
  };

  t3codeNightly = pkgs.symlinkJoin {
    name = "t3code-nightly";
    paths = [
      launcher
      desktopItem
    ];
    postBuild = ''
      install -Dm444 ${./t3code-nightly.svg} \
        "$out/share/icons/hicolor/scalable/apps/t3code-nightly.svg"
    '';
  };
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [ t3codeNightly ];
}
