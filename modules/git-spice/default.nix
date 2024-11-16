{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.git-spice.enable {
    home = {
      packages = [
        (pkgs.callPackage ../../packages/git-spice {
          installed-binary-name = config.git-spice.installed-binary-name;
        })
      ];
    };
  };

  options = {
    git-spice = {
      enable = lib.mkEnableOption "git-spice";

      installed-binary-name = lib.mkOption {
        default = "gs";
        description = "Alternative name to install `gs` binary as.";
        example = "git-spice";
        type = lib.types.str;
      };
    };
  };
}
