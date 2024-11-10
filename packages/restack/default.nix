{ fetchzip
, stdenv
}:

let
  pname = "restack";

  src = fetchzip {
    sha256 = "sha256:1bngm2y13wj3wa0rwrvaa7ggr7ih85crpk5l7jwjg7wg66fhyjgn";

    url = "https://github.com/abhinav/restack/releases/download/v${version}/restack-darwin-amd64.tar.gz";
  };

  version = "0.8.0";
in

stdenv.mkDerivation {
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D ${src} $out/bin/${pname}
    runHook postInstall
  '';

  inherit pname;

  inherit src;

  inherit version;
}
