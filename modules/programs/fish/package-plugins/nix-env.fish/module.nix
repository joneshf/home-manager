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

            package = pkgs.callPackage ../../../../../lib/mk-package-option.nix { } pkgs "nix-env.fish" {
              default = pkgs.callPackage ../../../../../packages/nix-env.fish/package.nix { };
            };
          };
        };
      };
    };
  };
}
