{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.git-spice.enable {
    home = {
      packages = [
        (config.programs.git-spice.package.override {
          installed-binary-name = config.programs.git-spice.installed-binary-name;
        })
      ];
    };
  };

  options = {
    programs = {
      git-spice = {
        enable = lib.options.mkEnableOption "git-spice";

        installed-binary-name = lib.options.mkOption {
          default = "gs";
          description = "Alternative name to install `gs` binary as.";
          example = "git-spice";
          type = lib.types.str;
        };

        package =
          lib.options.mkPackageOption pkgs "git-spice" {
            # We want to use the package defined in `../../../packages/git-spice/package.nix` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../../packages/git-spice/package.nix` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../../packages/git-spice/package.nix { };
          };
      };
    };
  };
}
