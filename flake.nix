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

      ref = "release-24.05";

      repo = "home-manager";

      type = "github";
    };

    nixpkgs = {
      owner = "nixos";

      ref = "nixos-24.05";

      repo = "nixpkgs";

      type = "github";
    };

    nixpkgs-unstable = {
      owner = "NixOS";

      ref = "nixos-unstable";

      repo = "nixpkgs";

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

          overlay-unstable = final: prev: { unstable = prev.callPackage inputs.nixpkgs-unstable { }; };
        in
        {
          homeConfigurations = {
            "joneshf" = inputs.home-manager.lib.homeManagerConfiguration {
              # Optionally use extraSpecialArgs to pass through arguments to home.nix.

              modules = [
                ./home.nix
                module-overlays
                inputs._1password-shell-plugins.hmModules.default
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
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          pre-commit = {
            settings = {
              hooks = {
                nil = {
                  enable = true;
                };

                nixfmt-rfc-style = {
                  enable = true;
                };
              };
            };
          };
        };

      systems = inputs.nixpkgs.lib.systems.flakeExposed;
    };
}
