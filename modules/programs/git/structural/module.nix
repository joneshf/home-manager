{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.git.structural.enable {
    home = {
      packages = [
        config.programs.git.structural.package
      ];
    };

    programs = {
      git = {
        aliases =
          let
            difft = lib.meta.getExe config.programs.git.structural.package;
          in
          {
            diff-structural = "-c diff.external=${difft} diff";

            log-structural = "-c diff.external=${difft} log --ext-diff";

            show-structural = "-c diff.external=${difft} show --ext-diff";
          };
      };
    };
  };

  options = {
    programs = {
      git = {
        structural = {
          enable = lib.options.mkEnableOption "git structural";

          package = pkgs.callPackage ../../../../lib/mk-package-option.nix { } pkgs "difftastic" { };
        };
      };
    };
  };
}
