{
  fetchzip,
  stdenv,
  ...
}:

let
  application-bundle = "Godot.app";

  binary-name = "Godot";

  hash = "sha256-8SHCS6Xn8TE/PDVp87lgkHZZL2T70q5NALOK5SVzbjU=";

  pname = "godot";

  version = "4.4.1-stable";

  zip-basename = "Godot_v${version}_macos.universal.zip";
in

stdenv.mkDerivation {
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/Applications $out/bin
    cp -a "$src/${application-bundle}" $out/Applications
    ln --symbolic "$out/Applications/${application-bundle}/Contents/MacOS/${binary-name}" $out/bin/${pname}

    runHook postInstall
  '';

  inherit pname;

  src = fetchzip {
    hash = hash;

    stripRoot = false;

    url = "https://github.com/godotengine/godot/releases/download/${version}/${zip-basename}";
  };

  inherit version;
}
