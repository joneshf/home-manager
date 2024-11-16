{ fetchzip
, git
, installShellFiles
  # `git-spice` produces a binary called `gs`,
  # which can conflict with binaries from other packages
  # (like `ghostscript`'s `gs` binary).
  # Setting `installed-binary-name` will install `gs` as a different name.
, installed-binary-name ? "gs"
, stdenv
, ...
}:

let
  original-binary-name = "gs";

  platform =
    if stdenv.hostPlatform.isCygwin then
      if stdenv.hostPlatform.isAarch64 then
        {
          sha256 = "sha256-yXQUPRsMn6h9uX6qaGa910Vv7aXYuMm4Sflmt2q65/k=";
          tarball-basename = "git-spice.Windows-arm64.tar.gz";
        }
      else if stdenv.hostPlatform.isx86_64 then
        {
          sha256 = "sha256-6m0ByoPiPtQVHVPnAaBEXh87agQ53zj8ZM6V0Xa0eB8=";
          tarball-basename = "git-spice.Windows-x86_64.tar.gz";
        }
      else
        throw "Unsupported architecture: ${stdenv.hostPlatform.config}"
    else if stdenv.hostPlatform.isDarwin then
      if stdenv.hostPlatform.isAarch64 then
        {
          sha256 = "sha256-MbO0JrR4cBS88fDLD+LfsOMHw+3d3uPZ8ILPTAfEG3s=";
          tarball-basename = "git-spice.Darwin-arm64.tar.gz";
        }
      else if stdenv.hostPlatform.isx86_64 then
        {
          sha256 = "sha256-x/yC/Vv3gSkx93SBBZo2afxbVGVL2N4RPwRHKVerqOw=";
          tarball-basename = "git-spice.Darwin-x86_64.tar.gz";
        }
      else
        throw "Unsupported architecture: ${stdenv.hostPlatform.config}"
    else if stdenv.hostPlatform.isLinux then
      if stdenv.hostPlatform.isAarch64 then
        {
          sha256 = "sha256-RcVjhBssUMY5BMk/kEpDPxXv/P+7KuQ1l7ngJH2zwUE=";
          tarball-basename = "git-spice.Linux-aarch64.tar.gz";
        }
      else if stdenv.hostPlatform.isx86_64 then
        {
          sha256 = "sha256-S03W98JOYAayjSBdjyCKtDHdQkyylTcBFMTaNUSYCCI=";
          tarball-basename = "git-spice.Linux-x86_64.tar.gz";
        }
      else
        throw "Unsupported architecture: ${stdenv.hostPlatform.config}"
    else
      throw "Unsupported operating system: ${stdenv.hostPlatform.config}";

  pname = "git-spice";

  src = fetchzip {
    sha256 = platform.sha256;

    stripRoot = false;

    url = "https://github.com/abhinav/git-spice/releases/download/v${version}/${platform.tarball-basename}";
  };

  version = "0.8.1";
in

stdenv.mkDerivation {
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D ${src}/${original-binary-name} $out/bin/${installed-binary-name}
    runHook postInstall
  '';

  nativeBuildInputs = [
    git
    installShellFiles
  ];

  inherit pname;

  postInstall = ''
    set -o errexit
    set -o pipefail
    set -o xtrace
    installShellCompletion \
        --cmd ${installed-binary-name} \
        --bash <($out/bin/${installed-binary-name} shell completion bash) \
        --fish <($out/bin/${installed-binary-name} shell completion fish) \
        --zsh <($out/bin/${installed-binary-name} shell completion zsh)
  '';

  inherit src;

  inherit version;
}
