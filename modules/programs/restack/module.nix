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

          package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "git-restack" {
            default = pkgs.callPackage ../../../packages/git-restack/package.nix { };
          };
        };

        package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "restack" {
          default = pkgs.callPackage ../../../packages/restack/package.nix { };
        };
      };
    };
  };
}
