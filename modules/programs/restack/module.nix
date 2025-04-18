{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.restack.enable {
    home = {
      packages =
        [ config.programs.restack.package ]
        ++ lib.lists.optional config.programs.restack.git-restack.enable config.programs.restack.git-restack.package
        ++ [ ];
    };
  };

  options = {
    programs = {
      restack = {
        enable = lib.options.mkEnableOption "restack";

        git-restack = {
          enable = lib.options.mkEnableOption "git-restack" // {
            default = true;
          };

          package =
            lib.options.mkPackageOption pkgs "git-restack" {
              # We want to use the package defined in `../../../packages/git-restack/package.nix` as the default.
              # This option has to be a `string | [string]` based on the path within `pkgs`.
              # The package in `../../../packages/git-restack/package.nix` isn't within `pkgs`.
              # So we set this to `null` explicitly,
              # and set the actual `default` below where we can use full `nix` syntax.
              default = null;
            }
            // {
              default = pkgs.callPackage ../../../packages/git-restack/package.nix { };
            };
        };

        package =
          lib.options.mkPackageOption pkgs "restack" {
            # We want to use the package defined in `../../../packages/restack/package.nix` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../../packages/restack/package.nix` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../../packages/restack/package.nix { };
          };
      };
    };
  };
}
