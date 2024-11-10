{ config
, lib
, pkgs
, ...
}:

{
  config = lib.mkIf config.nix-env_fish.enable {
    programs = {
      fish = {
        plugins = [
          {
            name = "nix-env.fish";

            src = (pkgs.callPackage ../../packages/nix-env.fish { }).src;
          }
        ];
      };
    };
  };

  options = {
    nix-env_fish = {
      enable = lib.mkEnableOption "nix-env.fish";
    };
  };
}
