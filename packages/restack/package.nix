{
  callPackage,
  fetchzip,
  stdenv,
  ...
}:

let
  platform = callPackage ../../lib/for-host-platform.nix { } {
    aarch64-darwin = {
      hash = "sha256-XpASU8eKdmsdkYsR98G5BGavrlGVsl01BDJcJ41uThA=";
      tarball-basename = "restack-darwin-arm64.tar.gz";
    };
    aarch64-linux = {
      hash = "sha256-ZuJju/jpFq1GGnWiC9Id3F2vjIijOddcw1eVblQqadk=";
      tarball-basename = "restack-linux-arm64.tar.gz";
    };
    x86_64-darwin = {
      hash = "sha256-WH2sx/kyBCoKUE8jabF8/IwQaARRHi56TwoPNhMyJs0=";
      tarball-basename = "restack-darwin-amd64.tar.gz";
    };
    x86_64-linux = {
      hash = "sha256-NVDUQS0I99PAyKdOe59rx/iBGUYLaY0c9mSJ+RWNoNc=";
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
    install -D $src/${pname} $out/bin/${pname}
    runHook postInstall
  '';

  inherit pname;

  src = fetchzip {
    hash = platform.hash;

    url = "https://github.com/abhinav/restack/releases/download/v${version}/${platform.tarball-basename}";
  };

  inherit version;
}
