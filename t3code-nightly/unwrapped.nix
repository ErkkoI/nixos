{
  cacert,
  copyDesktopItems,
  electron_44,
  fetchFromGitHub,
  fetchPnpmDeps,
  installShellFiles,
  jq,
  lib,
  libsecret,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  node-gyp,
  nodejs_26,
  pkg-config,
  pnpm_12,
  pnpmBuildHook,
  pnpmConfigHook,
  python3,
  spdx-license-list-data,
  stdenv,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    appName = "T3 Code (Nightly)";
    electron = electron_44;
    nodejs = nodejs_26;
    pnpm = pnpm_12;
    desktopIcon = "assets/prod/black-universal-1024.png";

  in
  {
    pname = "t3code-nightly-unwrapped";
    version = "0.1.12-nightly.20261121.5038";
    strictDeps = true;
    __structuredAttrs = true;

    src = fetchFromGitHub {
      owner = "pingdotgg";
      repo = "t3code";
      tag = "v${finalAttrs.version}";
      hash = "sha256-VzVDug4S3g4dqFibvoV+r+UhjeuPb8KH1XcJ+fUiOCU=";
    };

    postPatch = ''
      substituteInPlace apps/web/vite.config.ts \
        --replace-fail 'const host = explicitHost || "localhost";' \
                       'const host = explicitHost || "127.0.0.1";'

      mkdir -p .generated/third-party-licenses/spdx/v3.28.0
      cp ${spdx-license-list-data.json}/json/details/*.json \
        .generated/third-party-licenses/spdx/v3.28.0
    '';

    nativeBuildInputs = [
      cacert
      copyDesktopItems
      installShellFiles
      jq
      makeBinaryWrapper
      node-gyp
      nodejs
      pkg-config
      pnpm
      pnpmBuildHook
      pnpmConfigHook
      python3
    ];

    buildInputs = [ libsecret ];

    pnpmWorkspaces = [
      "@t3tools/monorepo"
      "t3..."
      "@t3tools/desktop..."
      "@t3tools/scripts..."
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit pnpm;
      inherit (finalAttrs)
        pname
        version
        src
        pnpmWorkspaces
        ;

      fetcherVersion = 5;
      hash = "sha256-i2Rpux1/w4po7UDS9G9Rxo6eR8/8jzKgO5Jjrr9Jrco=";
    };

    preBuild = ''
      export pnpm_config_verify_deps_before_run=false

      node scripts/update-release-package-versions.ts ${finalAttrs.version}

      export npm_config_nodedir=${nodejs}
      export ELECTRON_SKIP_BINARY_DOWNLOAD=1
      pnpm rebuild --pending "''${pnpmInstallFlags[@]}" --filter '!@t3tools/monorepo'
    '';

    pnpmBuildScript = "build:desktop";

    postBuild = ''
      pnpm vp cache clean
    '';

    dontPatchELF = true;
    noAuditTmpdir = true;

    installPhase = ''
      runHook preInstall

      mkdir --parents "$out"/libexec/t3code/apps/desktop "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode node_modules "$out"/libexec/t3code
      cp --recursive --no-preserve=mode apps/server/{node_modules,dist} "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode \
        apps/desktop/{node_modules,dist-electron} \
        "$out"/libexec/t3code/apps/desktop

      # Electron derives the app name, and with it the safeStorage keyring /
      # Keychain identity, from `productName` or `name`. Use `t3code` like the
      # official builds so encrypted data stays readable across rebrands.
      jq '.name = "t3code" | del(.productName)' apps/desktop/package.json \
        > "$out"/libexec/t3code/apps/desktop/package.json

      mkdir --parents "$out"/libexec/t3code/apps/desktop/prod-resources
      install --mode=444 ${desktopIcon} \
        "$out"/libexec/t3code/apps/desktop/prod-resources/icon.png

      install -Dm755 \
        native/browser-secret/build/${stdenv.hostPlatform.node.arch}/t3-browser-secret \
        "$out"/libexec/t3code/apps/desktop/prod-resources/browser-secret/t3-browser-secret

      find "$out"/libexec/t3code -xtype l -delete

      makeWrapper ${lib.getExe nodejs} "$out"/bin/t3 \
        --add-flags "$out"/libexec/t3code/apps/server/dist/bin.mjs

      makeWrapper ${lib.getExe electron} "$out"/bin/t3code-desktop \
        --add-flags "$out"/libexec/t3code/apps/desktop \
        --inherit-argv0

      mkdir --parents \
        "$out"/share/icons/hicolor/{1024x1024,scalable}/apps
      install --mode=444 ${desktopIcon} \
        "$out"/share/icons/hicolor/1024x1024/apps/t3code-nightly.png
      install --mode=444 assets/prod/logo.svg \
        "$out"/share/icons/hicolor/scalable/apps/t3code-nightly.svg

      runHook postInstall
    '';

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      for shell in bash fish zsh; do
        installShellCompletion --cmd t3 --"$shell" <("$out/bin/t3" --completions "$shell")
      done
    '';

    postFixup = ''
      # Electron's Node runtime does not provide libstdc++ for the bundled node-pty prebuild
      for module in "$out"/libexec/t3code/node_modules/.pnpm/node-pty@*/node_modules/node-pty/prebuilds/linux-${stdenv.hostPlatform.node.arch}/pty.node; do
        patchelf --add-rpath ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]} "$module"
      done
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "t3code-nightly";
        desktopName = appName;
        comment = "Minimal web GUI for coding agents";
        exec = "t3code-desktop %U";
        terminal = false;
        icon = "t3code-nightly";
        startupWMClass = "t3code";
        categories = [ "Development" ];
      })
    ];

    passthru = {
      updateScript = nix-update-script {
        attrPath = "t3code-nightly.unwrapped";
        extraArgs = [
          "--use-github-releases"
          "--version=unstable"
        ];
      };
    };

    meta = {
      description = "Minimal web GUI for coding agents (nightly)";
      homepage = "https://t3.codes";
      downloadPage = "https://t3.codes/download";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/${finalAttrs.src.tag}";
      license = lib.licenses.mit;
      mainProgram = "t3code-desktop";
      platforms = lib.platforms.linux;
    };
  }
)
