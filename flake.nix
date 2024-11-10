{
  description = "Home Manager configuration of joneshf";

  inputs = {
    _1password-shell-plugins = {
      owner = "1Password";

      ref = "main";

      repo = "shell-plugins";

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

  outputs = inputs:
    let
      module-overlays = { ... }: {
        nixpkgs = {
          overlays = [
            overlay-unstable
          ];
        };
      };

      overlay-unstable = final: prev: {
        unstable = prev.callPackage inputs.nixpkgs-unstable { };
      };
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

          pkgs = import inputs.nixpkgs {
            system = "x86_64-darwin";
          };
        };
      };
    };
}
