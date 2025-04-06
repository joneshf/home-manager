{
  bash,
  dotnet-sdk,
  fetchzip,
  findutils,
  lib,
  rsync,
  stdenv,
  xcbuild,
  ...
}:

let
  application-bundle = "Godot_mono.app";

  hash = "sha256-7b1t6ggis6QgRlBxaJ2JX7NBblQLFKAus+y25euyxxo=";

  pname = "godot-mono";

  version = "4.4.1-stable";

  zip-basename = "Godot_v${version}_mono_macos.universal.zip";
in

assert
  !stdenv.buildPlatform.isDarwin
  -> throw ''
    We need `osacompile` to build ${pname}, and that's only available on Darwin platforms.
  '';

stdenv.mkDerivation {
  buildInputs = [
    bash
    dotnet-sdk
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Set up the directories we need.
    mkdir --parents $out/Applications $out/bin $out/unpatched

    # This process is mostly following what's done in `mac-app-util`:
    # https://github.com/hraban/mac-app-util/blob/341ede93f290df7957047682482c298e47291b4d/main.lisp#L157-L161.
    # We don't do the touch at the end,
    # because it doesn't seem to fix the issue.

    # Put the actual application in the `unpatched` directory.
    # We need to wrap calls to this in a script that sets the environment.
    cp -a "$src/${application-bundle}" $out/unpatched

    # Create a script that sets the environment and runs the actual application.
    cat <<EOF > $out/bin/${pname}
    #!${lib.meta.getExe bash}

    DOTNET_ROOT='${dotnet-sdk}/share/dotnet' PATH="${
      lib.strings.makeBinPath [ dotnet-sdk ]
    }:$${PATH}" open '$out/unpatched/${application-bundle}'
    EOF
    chmod 0755 $out/bin/${pname}

    # Make a trampoline using the wrapper script.
    /usr/bin/osacompile \
      -e "do shell script \"$out/bin/${pname}\"" \
      -o "$out/Applications/${application-bundle}"

    # Copy over the icons.
    find "$out/Applications/${application-bundle}" -name '*.icns' -delete
    rsync \
      --include='*.icns' \
      --exclude='*' \
      --links \
      --recursive \
      "$out/unpatched/${application-bundle}/Contents/Resources/" \
      "$out/Applications/${application-bundle}/Contents/Resources/"

    # Copy the `Info.plist`,
    # and set the executable back to the trampoline's executable.
    cp "$out/unpatched/${application-bundle}/Contents/Info.plist" "$out/Applications/${application-bundle}/Contents/Info.plist"
    plutil -replace CFBundleExecutable -string applet "$out/Applications/${application-bundle}/Contents/Info.plist"

    runHook postInstall
  '';

  nativeBuildInputs = [
    findutils
    rsync
    xcbuild
  ];

  inherit pname;

  src = fetchzip {
    hash = hash;

    stripRoot = false;

    url = "https://github.com/godotengine/godot/releases/download/${version}/${zip-basename}";
  };

  inherit version;
}
