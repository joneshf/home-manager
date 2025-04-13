{
  callPackage,
  fetchzip,
  stdenv,
  ...
}:

let
  platform = callPackage ../../lib/for-host-platform.nix { } {
    aarch64-darwin = {
      sha256 = "sha256-rFnFjassYWANGOIDMrTjaygi8hMbY63ucSzIDrD7eaU=";
      tarball-basename = "restack-darwin-arm64.tar.gz";
    };
    aarch64-linux = {
      sha256 = "sha256-xvH61V82H3mAj8N3V8J2ZI+yl16byR6jEpwUjqWToBA=";
      tarball-basename = "restack-linux-arm64.tar.gz";
    };
    x86_64-darwin = {
      sha256 = "sha256-9kkPnTGPnye5PLTMm1lBMJ783lFqZ56B4kPyEbyoz64=";
      tarball-basename = "restack-darwin-amd64.tar.gz";
    };
    x86_64-linux = {
      sha256 = "sha256-J8+A/LsHGJ93S/PbbaYDjdSEKPOu5BvrdM5Pi9kakkQ=";
      tarball-basename = "restack-linux-amd64.tar.gz";
    };
  };

  pname = "restack";

  version = "0.8.0";
in

stdenv.mkDerivation {
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/${pname}
    runHook postInstall
  '';

  inherit pname;

  src = fetchzip {
    sha256 = platform.sha256;

    url = "https://github.com/abhinav/restack/releases/download/v${version}/${platform.tarball-basename}";
  };

  inherit version;
}
