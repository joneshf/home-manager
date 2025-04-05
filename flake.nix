{
  description = "Home Manager configuration of joneshf";

  inputs = {
    _1password-shell-plugins = {
      owner = "1Password";

      ref = "main";

      repo = "shell-plugins";

      type = "github";
    };

    flake-parts = {
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs-unstable";
        };
      };

      owner = "hercules-ci";

      ref = "main";

      repo = "flake-parts";

      type = "github";
    };

    git-hooks_nix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs-unstable";
        };

        nixpkgs-stable = {
          follows = "nixpkgs";
        };
      };

      owner = "cachix";

      ref = "master";

      repo = "git-hooks.nix";

      type = "github";
    };

    home-manager = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };

      owner = "nix-community";

      ref = "release-24.11";

      repo = "home-manager";

      type = "github";
    };

    mac-app-util = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };

      owner = "hraban";

      ref = "master";

      repo = "mac-app-util";

      type = "github";
    };

    nixpkgs = {
      owner = "nixos";

      ref = "nixos-24.11";

      repo = "nixpkgs";

      type = "github";
    };

    nixpkgs-unstable = {
      owner = "NixOS";

      ref = "nixos-unstable";

      repo = "nixpkgs";

      type = "github";
    };

    treefmt-nix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs-unstable";
        };
      };

      owner = "numtide";

      ref = "main";

      repo = "treefmt-nix";

      type = "github";
    };

  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        let
          module-overlays =
            { ... }:
            {
              nixpkgs = {
                overlays = [ overlay-unstable ];
              };
            };

          overlay-unstable = _final: prev: { unstable = prev.callPackage inputs.nixpkgs-unstable { }; };
        in
        {
          homeConfigurations = {
            "joneshf" = inputs.home-manager.lib.homeManagerConfiguration {
              # Optionally use extraSpecialArgs to pass through arguments to home.nix.

              modules = [
                ./home.nix
                module-overlays
                inputs._1password-shell-plugins.hmModules.default
                inputs.mac-app-util.homeManagerModules.default
              ];

              pkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
            };
          };

          homeManagerModules = {
            crane-completions = ./modules/crane-completions;

            default = ./modules;

            git-spice = ./modules/git-spice;

            nix-env_fish = ./modules/nix-env.fish;

            pdm = ./modules/pdm;

            restack = ./modules/restack;
          };
        };

      imports = [ inputs.git-hooks_nix.flakeModule ];

      perSystem =
        { config, pkgs, ... }:
        {
          devShells = {
            default = pkgs.mkShell {
              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };
          };

          formatter = pkgs.nixfmt-rfc-style;

          pre-commit = {
            settings = {
              hooks = {
                deadnix = {
                  enable = true;
                };

                detect-aws-credentials = {
                  enable = true;
                };

                detect-private-keys = {
                  enable = true;
                };

                forbid-new-submodules = {
                  enable = true;
                };

                markdownlint = {
                  enable = true;

                  settings = {
                    configuration = {
                      MD013 = {
                        # We'd like to use something like `wrap:inner-sentence`:
                        # https://cirosantilli.com/markdown-style-guide/#option-wrap-inner-sentence,
                        # or something related to SemBr: https://sembr.org/.
                        # But that's stymied in an issue: https://github.com/DavidAnson/markdownlint/issues/298.
                        #
                        # We set the line length to something large enough to not get hit by it regularly.
                        line_length = 1000;
                      };
                    };
                  };
                };

                nil = {
                  enable = true;
                };

                nixfmt-rfc-style = {
                  enable = true;
                };

                typos = {
                  enable = true;
                };
              };
            };
          };
        };

      systems = inputs.nixpkgs.lib.systems.flakeExposed;
    };
}
