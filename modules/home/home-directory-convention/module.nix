{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.home.home-directory-convention.enable {
    home = {
      homeDirectory = pkgs.callPackage ../../../lib/for-host-platform.nix { } {
        aarch64-darwin = "/Users/${config.home.username}";
        aarch64-linux = "/home/${config.home.username}";
        x86_64-darwin = "/Users/${config.home.username}";
        x86_64-linux = "/home/${config.home.username}";
      };
    };
  };

  options = {
    home = {
      home-directory-convention = {
        enable = lib.options.mkEnableOption "home directory convention" // {
          default = true;
          description = "Sets `home.homeDirectory` to the platform convention. I.e. `/Users/<home.username>` on Darwin and `/home/<home.username>` on Linux.";
        };
      };
    };
  };
}
