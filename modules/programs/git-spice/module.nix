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
        (pkgs.callPackage ../../../packages/git-spice/package.nix {
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
      };
    };
  };
}
