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

        package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "git-spice" {
          default = pkgs.callPackage ../../../packages/git-spice/package.nix { };
        };
      };
    };
  };
}
