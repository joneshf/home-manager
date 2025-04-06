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
        ++ lib.lists.optional config.godot.mono.enable config.godot.mono.package
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

        package =
          lib.mkPackageOption pkgs "Godot_mono" {
            # We want to use the package defined in `../../packages/godot-mono` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../packages/godot-mono` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../packages/godot-mono { };
          };
      };

      package =
        lib.mkPackageOption pkgs "Godot" {
          # We want to use the package defined in `../../packages/godot` as the default.
          # This option has to be a `string | [string]` based on the path within `pkgs`.
          # The package in `../../packages/godot` isn't within `pkgs`.
          # So we set this to `null` explicitly,
          # and set the actual `default` below where we can use full `nix` syntax.
          default = null;
        }
        // {
          default = pkgs.callPackage ../../packages/godot { };
        };
    };
  };
}
