{ config, lib, ... }:

{
  config = lib.modules.mkIf config.commit-signing.enable {
    home = {
      file = {
        ${config.commit-signing.ssh.allowed-signers-file} = {
          text = "${config.commit-signing.ssh.email} ${config.commit-signing.ssh.public-key}";
        };
      };
    };

    programs = {
      git =
        lib.modules.mkIf (config.programs.git.enable && config.commit-signing.enable-git-integration)
          {
            extraConfig = {
              commit = {
                gpgSign = true;
              };

              gpg = {
                format = "ssh";

                ssh =
                  {
                    allowedSignersFile = "${config.home.homeDirectory}/${config.commit-signing.ssh.allowed-signers-file}";
                  }
                  // lib.attrsets.optionalAttrs (config.commit-signing.ssh.program != null) {
                    program = config.commit-signing.ssh.program;
                  }
                  // { };
              };

              tag = {
                gpgSign = true;
              };

              user = {
                signingKey = config.commit-signing.ssh.public-key;
              };
            };
          };

      jujutsu =
        lib.modules.mkIf
          (config.programs.jujutsu.enable && config.commit-signing.enable-jujutsu-integration)
          {
            settings = {
              signing = {
                backend = "ssh";

                backends = {
                  ssh =
                    {
                      allowed-signers = "${config.home.homeDirectory}/${config.commit-signing.ssh.allowed-signers-file}";
                    }
                    // lib.attrsets.optionalAttrs (config.commit-signing.ssh.program != null) {
                      program = config.commit-signing.ssh.program;
                    }
                    // { };
                };

                behavior = "own";

                key = config.commit-signing.ssh.public-key;
              };
            };
          };
    };
  };

  options = {
    commit-signing = {
      enable = lib.options.mkEnableOption "commit signing";

      enable-git-integration = lib.options.mkEnableOption "git integration" // {
        default = true;
      };

      enable-jujutsu-integration = lib.options.mkEnableOption "jujutsu integration" // {
        default = true;
      };

      ssh = {
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
}
