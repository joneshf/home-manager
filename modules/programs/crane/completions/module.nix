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

          package = pkgs.callPackage ../../../../lib/mk-package-option.nix { } pkgs "crane-completions" {
            default = pkgs.callPackage ../../../../packages/crane-completions/package.nix { };
          };
        };
      };
    };
  };
}
