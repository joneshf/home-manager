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

            src = (pkgs.callPackage ../../../../../packages/nix-env.fish/package.nix { }).src;
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
          };
        };
      };
    };
  };
}
