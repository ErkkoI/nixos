{
  lib,
  rustPlatform,
  t3code-unwrapped,
}:

rustPlatform.buildRustPackage {
  pname = "t3code-nightly-resource-monitor";
  inherit (t3code-unwrapped) version src;

  sourceRoot = "${t3code-unwrapped.src.name}/native/resource-monitor";

  cargoHash = "sha256-5cmG2daM1bVOA23gjjoalbx0fEL1hmqV6WZov0sUZp8=";

  meta = {
    description = "Native resource diagnostics sidecar for T3 Code (nightly)";
    inherit (t3code-unwrapped.meta)
      homepage
      changelog
      license
      platforms
      ;
    mainProgram = "t3-resource-monitor";
  };
}
