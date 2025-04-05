{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.godot.enable {
    home = {
      packages = [
        config.godot.package
      ];
    };
  };

  options = {
    godot = {
      enable = lib.mkEnableOption "godot";

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
