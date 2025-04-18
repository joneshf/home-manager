{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.crane.completions.enable {
    home = {
      packages = [ config.programs.crane.completions.package ];
    };
  };

  options = {
    programs = {
      crane = {
        completions = {
          enable = lib.options.mkEnableOption "crane completions";

          package =
            lib.options.mkPackageOption pkgs "crane-completions" {
              # We want to use the package defined in `../../../../packages/crane-completions/package.nix` as the default.
              # This option has to be a `string | [string]` based on the path within `pkgs`.
              # The package in `../../../../packages/crane-completions/package.nix` isn't within `pkgs`.
              # So we set this to `null` explicitly,
              # and set the actual `default` below where we can use full `nix` syntax.
              default = null;
            }
            // {
              default = pkgs.callPackage ../../../../packages/crane-completions/package.nix { };
            };
        };
      };
    };
  };
}
