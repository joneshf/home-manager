{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.fish.package-plugins."nix-env.fish".enable {
    programs = {
      fish = {
        plugins = [
          {
            name = "nix-env.fish";

            src = config.programs.fish.package-plugins."nix-env.fish".package.src;
          }
        ];
      };
    };
  };

  options = {
    programs = {
      fish = {
        package-plugins = {
          "nix-env.fish" = {
            enable = lib.options.mkEnableOption "nix-env.fish";

            package =
              lib.options.mkPackageOption pkgs "nix-env.fish" {
                # We want to use the package defined in `../../../../../packages/nix-env.fish/package.nix` as the default.
                # This option has to be a `string | [string]` based on the path within `pkgs`.
                # The package in `../../../../../packages/nix-env.fish/package.nix` isn't within `pkgs`.
                # So we set this to `null` explicitly,
                # and set the actual `default` below where we can use full `nix` syntax.
                default = null;
              }
              // {
                default = pkgs.callPackage ../../../../../packages/nix-env.fish/package.nix { };
              };
          };
        };
      };
    };
  };
}
