{
  lib,
  fetchurl,
  linkFarm,
}:
let
  pack = lib.importTOML ./pack.toml;
  index = lib.importTOML ./${pack.index.file};
  packFiles = lib.concatMap (
    info:
    let
      inherit (info) file;
    in
    if info.metafile or false then
      let
        meta = lib.importTOML ./${file};
        directory = dirOf file;
        targetFile = lib.optionalString (directory != "") (directory + "/") + meta.filename;
        isServerSide = meta.side or "both" != "client";
      in
      lib.optional isServerSide {
        name = targetFile;
        path = fetchurl {
          url = meta.download.url;
          hash = "${meta.download.hash-format}-${meta.download.hash}";
        };
      }
    else
      lib.singleton {
        name = file;
        path = ./${file};
      }
  ) index.files;
in
(linkFarm "modpack" packFiles).overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru or { } // {
      inherit pack index;
    };
  }
)
