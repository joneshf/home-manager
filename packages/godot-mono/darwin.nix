{
  fetchzip,
  lib,
  makeBinaryWrapper,
  override-dotnet-sdk,
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
    override-dotnet-sdk
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Set up the directories we need.
    mkdir --parents $out/Applications $out/bin $out/unpatched

    # Put the actual application in the `unpatched` directory.
    # We need to wrap calls to this in a script that sets the environment.
    cp -a "$src/${application-bundle}" $out/unpatched

    # Symlink everything from the unpacked application bundle except the `MacOS` directory.
    mkdir --parents "$out/Applications/${application-bundle}/Contents"
    shopt -s extglob
    ln --symbolic "$out/unpatched/${application-bundle}/Contents/"!(MacOS) "$out/Applications/${application-bundle}/Contents/"
    shopt -u extglob

    # Wrap the actual binary with the `DOTNET_ROOT` environment variable set,
    # and make it available on the `PATH`.
    makeBinaryWrapper \
      "$out/unpatched/${application-bundle}/Contents/MacOS/${binary-name}" \
      "$out/Applications/${application-bundle}/Contents/MacOS/${binary-name}" \
      --prefix PATH : ${lib.strings.makeBinPath [ override-dotnet-sdk ]} \
      --set DOTNET_ROOT ${override-dotnet-sdk}/share/dotnet
    ln --symbolic "$out/Applications/${application-bundle}/Contents/MacOS/${binary-name}" "$out/bin/${pname}"

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
