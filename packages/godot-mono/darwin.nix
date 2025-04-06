{
  dotnet-sdk,
  fetchzip,
  lib,
  makeBinaryWrapper,
  stdenv,
  ...
}:

let
  application-bundle = "Godot_mono.app";

  binary-name = "Godot";

  hash = "sha256-7b1t6ggis6QgRlBxaJ2JX7NBblQLFKAus+y25euyxxo=";

  pname = "godot-mono";

  version = "4.4.1-stable";

  zip-basename = "Godot_v${version}_mono_macos.universal.zip";
in

stdenv.mkDerivation {
  buildInputs = [
    dotnet-sdk
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/Applications $out/bin
    cp -a "$src/${application-bundle}" $out/Applications
    makeBinaryWrapper \
      "$out/Applications/${application-bundle}/Contents/MacOS/${binary-name}" \
      $out/bin/${pname} \
      --prefix PATH : ${lib.strings.makeBinPath [ dotnet-sdk ]} \
      --set DOTNET_ROOT "${dotnet-sdk}/share/dotnet"

    runHook postInstall
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  inherit pname;

  src = fetchzip {
    hash = hash;

    stripRoot = false;

    url = "https://github.com/godotengine/godot/releases/download/${version}/${zip-basename}";
  };

  inherit version;
}
