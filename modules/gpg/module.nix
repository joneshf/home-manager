{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.gpg.enable (
    lib.modules.mkMerge [
      {
        programs = {
          gpg = {
            enable = true;

            package = config.gpg.package;
          };
        };
      }

      (lib.modules.mkIf config.gpg.public-keys.github.enable {
        programs = {
          gpg = {
            publicKeys = [
              {
                source = config.gpg.public-keys.github.source;
              }
            ];
          };
        };
      })

      (lib.modules.mkIf config.programs.pdm.enableBashIntegration {
        programs = {
          bash = {
            initExtra = ''
              export GPG_TTY=$(tty)
            '';
          };
        };
      })

      (lib.modules.mkIf config.programs.pdm.enableFishIntegration {
        programs = {
          fish = {
            shellInit = ''
              set --export GPG_TTY (tty)
            '';
          };
        };
      })

      (lib.modules.mkIf config.programs.pdm.enableNushellIntegration {
        programs = {
          nushell = {
            extraEnv = ''
              $env.GPG_TTY = (tty)
            '';
          };
        };
      })

      (lib.modules.mkIf config.programs.pdm.enableZshIntegration {
        programs = {
          zsh = {
            initExtra = ''
              export GPG_TTY=$(tty)
            '';
          };
        };
      })
    ]
  );

  options = {
    gpg = {
      enable = lib.options.mkEnableOption "gpg";

      enableBashIntegration = lib.options.mkEnableOption "Bash integration" // {
        default = config.gpg.enable && config.programs.bash.enable;
      };

      enableFishIntegration = lib.options.mkEnableOption "Fish integration" // {
        default = config.gpg.enable && config.programs.fish.enable;
      };

      enableNushellIntegration = lib.options.mkEnableOption "Nushell integration" // {
        default = config.gpg.enable && config.programs.nushell.enable;
      };

      enableZshIntegration = lib.options.mkEnableOption "Zsh integration" // {
        default = config.gpg.enable && config.programs.zsh.enable;
      };

      package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "gnupg" { };

      public-keys = {
        github = {
          enable = lib.options.mkEnableOption "importing GitHub public GPG key" // {
            default = config.gpg.enable;
          };

          source = lib.options.mkOption {
            default = pkgs.fetchurl {
              hash = "sha256-bor2h/YM8/QDFRyPsbJuleb55CTKYMyPN4e9RGaj74Q=";
              url = "https://github.com/web-flow.gpg";
            };
            description = "Path of an OpenPGP public key file.";
            type = lib.types.path;
          };
        };
      };
    };
  };
}
