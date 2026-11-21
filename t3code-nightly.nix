{
  appimageTools,
  fetchurl,
}:
let
  pname = "t3code-nightly";
  version = "0.1.12-nightly.20261121.5038";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-Nightly-x86_64.AppImage";
    hash = "sha256-UAP7yzbJO/ZTLxGMVrjkpdKm8lfoCPeaXAY9+0byUC4=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  dieWithParent = false;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/t3code.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}' \
      --replace-fail 'Icon=t3code' 'Icon=${pname}'

    cp -r ${appimageContents}/usr/share/icons $out/share
    chmod -R u+w $out/share/icons
    find $out/share/icons -name 't3code.png' -execdir mv {} '${pname}.png' \;
  '';
}
