{ config, lib, ... }:

{
  config = lib.modules.mkIf config.programs.sapling.gpg-signing.enable {
    assertions = [
      {
        assertion = builtins.hasAttr "userEmail" config.programs.sapling;
        message = "`programs.sapling.userEmail` must be set to use GPG signing";
      }
      {
        assertion = builtins.hasAttr "userName" config.programs.sapling;
        message = "`programs.sapling.userName` must be set to use GPG signing";
      }
    ];

    programs = {
      sapling = {
        extraConfig = {
          gpg = {
            key = config.programs.sapling.gpg-signing.key;
          };
        };
      };
    };
  };

  options = {
    programs = {
      sapling = {
        gpg-signing = {
          enable = lib.options.mkEnableOption "Sapling GPG signing";

          key = lib.options.mkOption {
            description = "The GPG key to use for signing.";
            example = "B577AA76BAE505B1";
            type = lib.types.str;
          };
        };
      };
    };
  };
}
