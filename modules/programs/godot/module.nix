{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.godot.enable {
    home = {
      packages =
        [ config.programs.godot.package ]
        ++ lib.lists.optional config.programs.godot.mono.enable (
          config.programs.godot.mono.package.override {
            override-dotnet-sdk = config.programs.godot.mono.override-dotnet-sdk;
          }
        )
        ++ [ ];
    };
  };

  options = {
    programs = {
      godot = {
        enable = lib.options.mkEnableOption "godot";

        mono = {
          enable = lib.options.mkEnableOption "mono" // {
            default = true;
          };

          override-dotnet-sdk = lib.options.mkPackageOption pkgs [ "dotnetCorePackages" "sdk_8_0" ] {
            nullable = true;
          };

          package =
            lib.options.mkPackageOption pkgs "Godot_mono" {
              # We want to use the package defined in `../../packages/godot-mono/package.nix` as the default.
              # This option has to be a `string | [string]` based on the path within `pkgs`.
              # The package in `../../packages/godot-mono/package.nix` isn't within `pkgs`.
              # So we set this to `null` explicitly,
              # and set the actual `default` below where we can use full `nix` syntax.
              default = null;
            }
            // {
              default = pkgs.callPackage ../../../packages/godot-mono/package.nix { };
            };
        };

        package =
          lib.options.mkPackageOption pkgs "Godot" {
            # We want to use the package defined in `../../packages/godot/package.nix` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../packages/godot/package.nix` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../../packages/godot/package.nix { };
          };
      };
    };
  };
}
