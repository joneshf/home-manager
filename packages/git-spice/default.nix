{ fetchzip
, git
, installShellFiles
  # `git-spice` produces a binary called `gs`,
  # which can conflict with binaries from other packages
  # (like `ghostscript`'s `gs` binary).
  # Setting `installed-binary-name` will install `gs` as a different name.
, installed-binary-name ? "gs"
, stdenv
}:

let
  original-binary-name = "gs";

  pname = "git-spice";

  src = fetchzip {
    sha256 = "sha256-2YTDO2eU/KlE0ZD6p7kDFElG69AjZQKkoloWiRO1/ss=";

    stripRoot = false;

    url = "https://github.com/abhinav/git-spice/releases/download/v${version}/git-spice.Darwin-x86_64.tar.gz";
  };

  version = "0.8.0";
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
    # The completions don't respect a renamed binary.
    # So we `sed` them to use the `installed-binary-name`.
    installShellCompletion \
        --cmd ${installed-binary-name} \
        --bash <($out/bin/${installed-binary-name} shell completion bash | sed s/${original-binary-name}/${installed-binary-name}/g) \
        --fish <($out/bin/${installed-binary-name} shell completion fish | sed s/${original-binary-name}/${installed-binary-name}/g) \
        --zsh <($out/bin/${installed-binary-name} shell completion zsh | sed s/${original-binary-name}/${installed-binary-name}/g)
  '';

  inherit src;

  inherit version;
}
