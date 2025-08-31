{
  description = "Home Manager configuration of joneshf";

  inputs = {
    _1password-shell-plugins = {
      owner = "1Password";

      ref = "main";

      repo = "shell-plugins";

      type = "github";
    };

    brew-api = {
      flake = false;

      owner = "BatteredBunny";

      ref = "main";

      repo = "brew-api";

      type = "github";
    };

    brew-nix = {
      inputs = {
        brew-api = {
          follows = "brew-api";
        };

        nixpkgs = {
          follows = "nixpkgs";
        };
      };

      owner = "BatteredBunny";

      ref = "main";

      repo = "brew-nix";

      type = "github";
    };

    firefox-addons = {
      dir = "pkgs/firefox-addons";

      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };

      owner = "rycee";

      ref = "master";

      repo = "nur-expressions";

      type = "gitlab";
    };

    flake-parts = {
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs";
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

      ref = "master";

      repo = "home-manager";

      type = "github";
    };

    jjui = {
      inputs = {
        flake-parts = {
          follows = "flake-parts";
        };

        nixpkgs = {
          follows = "nixpkgs";
        };
      };

      owner = "idursun";

      ref = "v0.9.3";

      repo = "jjui";

      type = "github";
    };

    nixpkgs = {
      owner = "NixOS";

      ref = "nixos-unstable";

      repo = "nixpkgs";

      type = "github";
    };

    nixpkgs-stable = {
      owner = "nixos";

      ref = "nixos-25.05";

      repo = "nixpkgs";

      type = "github";
    };

    treefmt-nix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
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
      imports = [
        inputs.git-hooks_nix.flakeModule
      ];

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

          legacyPackages =
            let
              # Massage the flat list from the Homebrew JSON API into an attrset.
              casks = builtins.listToAttrs casks-entries;

              casks-entries = builtins.map (cask: {
                name = cask.token;
                value = cask;
              }) casks-list;

              casks-list = builtins.fromJSON (builtins.readFile "${inputs.brew-api}/cask.json");

              module-overlays =
                { ... }:
                {
                  nixpkgs = {
                    overlays = [
                      inputs.firefox-addons.overlays.default
                      overlay-brew-nix
                      overlay-jjui
                      overlay-stable
                    ];
                  };
                };

              overlay-brew-nix = final: prev: {
                brew-nix = builtins.mapAttrs (
                  pname: derivation:
                  let
                    cask = casks.${pname};

                    fetchurl-args =
                      if final.system == "aarch64-darwin" then
                        if pname == "chromium" then
                          {
                            sha256 = "sha256-9avP2xHh5II3WG2gzEDtrJmEwxTrpnsfY6qcqWHVSFk=";
                            url = cask.url;
                          }
                        else
                          prev.lib.attrsets.getAttrs [ "sha256" "url" ] cask
                      else if final.system == "x86_64-darwin" then
                        let
                          macOS-variation = "sequoia";
                        in
                        if pname == "chromium" then
                          {
                            sha256 = "sha256-lqvHrreXBUdZ/fAEPKNlnttj6uAIwIbV3Nv47BfqAFk=";
                            url = cask.variations.${macOS-variation}.url;
                          }
                        else
                          prev.lib.attrsets.attrByPath [ "variations" macOS-variation ] {
                            sha256 = prev.lib.strings.optionalString (cask.sha256 != "no_check") cask.sha256;
                            url = cask.url;
                          } cask
                      else
                        throw "Unknown system: ${builtins.currentSystem}";
                  in
                  derivation.overrideAttrs {
                    src = prev.fetchurl fetchurl-args;
                  }
                ) inputs.brew-nix.outputs.packages.${final.system};
              };

              overlay-jjui = final: _prev: { jjui = inputs.jjui.outputs.packages.${final.system}; };

              overlay-stable = _final: prev: { stable = prev.callPackage inputs.nixpkgs-stable { }; };
            in
            {
              homeConfigurations = {
                "joneshf" = inputs.home-manager.lib.homeManagerConfiguration {
                  # Optionally use extraSpecialArgs to pass through arguments to home.nix.

                  modules = [
                    { home.username = "joneshf"; }
                    ./home.nix
                    module-overlays
                    inputs._1password-shell-plugins.hmModules.default
                  ];

                  inherit pkgs;
                };
              };

              homeModules =
                import ./lib/modules-from-directory-recursive.nix {
                  directory = ./modules;

                  lib = pkgs.lib;
                }
                // {
                  "home.nix" = ./home.nix;
                };
            };

          packages = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = pkgs.callPackage;

            directory = ./packages;
          };

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
