{ config, lib, ... }:

{
  config = lib.modules.mkIf config.programs.git.ssh-signing.enable {
    home = {
      file = {
        ${config.programs.git.ssh-signing.allowed-signers-file} = {
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

            ssh =
              {
                allowedSignersFile = "${config.home.homeDirectory}/${config.programs.git.ssh-signing.allowed-signers-file}";
              }
              // lib.attrsets.optionalAttrs (config.programs.git.ssh-signing.program != null) {
                program = config.programs.git.ssh-signing.program;
              }
              // { };
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
          allowed-signers-file = lib.options.mkOption {
            default = ".ssh/allowed_signers";
            description = "The file to write the allowed signers to";
            type = lib.types.str;
          };

          email = lib.options.mkOption {
            default = "*";
            description = "The email to use for signing. Can also be `*` to allow any email to sign.";
            example = "me@example.com";
            type = lib.types.either (lib.types.enum [ "*" ]) lib.types.str;
          };

          enable = lib.options.mkEnableOption "git signing";

          program = lib.options.mkOption {
            default = null;
            description = "The program to use for signing. This is necessary when using a different program to sign commits, like 1Password.";
            example = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
            type = lib.types.nullOr lib.types.str;
          };

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
