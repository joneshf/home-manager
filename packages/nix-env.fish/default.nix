{ fetchFromGitHub, fishPlugins, ... }:

fishPlugins.buildFishPlugin {
  pname = "nix-env.fish";

  src = fetchFromGitHub {
    owner = "lilyball";

    repo = "nix-env.fish";

    rev = "7b65bd228429e852c8fdfa07601159130a818cfa";

    sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
  };

  version = "master";
}
