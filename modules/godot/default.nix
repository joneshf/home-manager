{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.godot.enable {
    home = {
      packages =
        [ config.godot.package ]
        ++ lib.lists.optional config.godot.mono.enable (
          config.godot.mono.package.override {
            override-dotnet-sdk = config.godot.mono.override-dotnet-sdk;
          }
        )
        ++ [ ];
    };
  };

  options = {
    godot = {
      enable = lib.mkEnableOption "godot";

      mono = {
        enable = lib.mkEnableOption "mono" // {
          default = true;
        };

        override-dotnet-sdk = lib.mkPackageOption pkgs [ "dotnetCorePackages" "sdk_8_0" ] {
          nullable = true;
        };

        package =
          lib.mkPackageOption pkgs "Godot_mono" {
            # We want to use the package defined in `../../packages/godot-mono/package.nix` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../packages/godot-mono/package.nix` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../packages/godot-mono/package.nix { };
          };
      };

      package =
        lib.mkPackageOption pkgs "Godot" {
          # We want to use the package defined in `../../packages/godot/package.nix` as the default.
          # This option has to be a `string | [string]` based on the path within `pkgs`.
          # The package in `../../packages/godot/package.nix` isn't within `pkgs`.
          # So we set this to `null` explicitly,
          # and set the actual `default` below where we can use full `nix` syntax.
          default = null;
        }
        // {
          default = pkgs.callPackage ../../packages/godot/package.nix { };
        };
    };
  };
}
