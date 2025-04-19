{ config, lib, ... }:

{
  config = lib.modules.mkIf config.programs.git.ssh-signing.enable {
    home = {
      file = {
        ".ssh/allowed_signers" = {
          text = "${config.programs.git.ssh-signing.email} ${config.programs.git.ssh-signing.public-key}";
        };
      };
    };

    programs = {
      git = {
        extraConfig = {
          commit = {
            gpgSign = true;
          };

          gpg = {
            format = "ssh";

            ssh = {
              allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";

              # TODO: Don't require 1Password.
              program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
            };
          };

          tag = {
            gpgSign = true;
          };

          user = {
            signingKey = config.programs.git.ssh-signing.public-key;
          };
        };
      };
    };
  };

  options = {
    programs = {
      git = {
        ssh-signing = {
          email = lib.options.mkOption {
            default = "*";
            description = "The email to use for signing. Can also be `*` to allow any email to sign.";
            example = "me@example.com";
            type = lib.types.either (lib.types.enum [ "*" ]) lib.types.str;
          };

          enable = lib.options.mkEnableOption "git signing";

          public-key = lib.options.mkOption {
            description = "The key to use for signing.";
            example = "ssh-ed25519 dead+beef+";
            type = lib.types.str;
          };
        };
      };
    };
  };
}
