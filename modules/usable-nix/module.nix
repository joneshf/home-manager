{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.usable-nix.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.usable-nix.direnv.enable (
        lib.modules.mkMerge [
          {
            programs = {
              direnv = {
                config = {
                  global = {
                    strict_env = true;
                  };
                };

                enable = true;
              };
            };
          }

          (lib.modules.mkIf config.usable-nix.direnv.nix-direnv.enable {
            programs = {
              direnv = {
                nix-direnv = {
                  enable = true;
                };
              };
            };
          })
        ]
      ))

      (lib.modules.mkIf config.usable-nix.home-manager.enable {
        programs = {
          home-manager = {
            enable = true;
          };
        };
      })

      (lib.modules.mkIf config.usable-nix.nh.enable (
        lib.modules.mkMerge [
          {
            programs = {
              nh = {
                enable = true;
              };
            };
          }

          (lib.modules.mkIf (config.usable-nix.nh.home-manager-flake != null) {
            home = {
              sessionVariables = {
                NH_HOME_FLAKE = config.usable-nix.nh.home-manager-flake;
              };
            };
          })

          (lib.modules.mkIf (config.usable-nix.nh.nix-darwin-flake != null) {
            home = {
              sessionVariables = {
                NH_DARWIN_FLAKE = config.usable-nix.nh.nix-darwin-flake;
              };
            };
          })
        ]
      ))

      (lib.modules.mkIf config.usable-nix.nil.enable {
        home = {
          packages = [
            config.usable-nix.nil.package
          ];
        };
      })

      (lib.modules.mkIf config.usable-nix.nix-output-monitor.enable {
        home = {
          packages = [
            config.usable-nix.nix-output-monitor.package
          ];
        };
      })

      (lib.modules.mkIf config.usable-nix.nixfmt-rfc-style.enable {
        home = {
          packages = [
            config.usable-nix.nixfmt-rfc-style.package
          ];
        };
      })
    ]
  );

  options = {
    usable-nix = {
      enable = lib.options.mkEnableOption "usable-nix";

      direnv = {
        enable = lib.options.mkEnableOption "direnv" // {
          default = config.usable-nix.enable;
        };

        nix-direnv = {
          enable = lib.options.mkEnableOption "nix-direnv" // {
            default = config.usable-nix.direnv.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "nix-direnv" { };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "direnv" { };
      };

      home-manager = {
        enable = lib.options.mkEnableOption "home-manager" // {
          default = config.usable-nix.enable;
        };
      };

      nh = {
        enable = lib.options.mkEnableOption "nh" // {
          default = config.usable-nix.enable;
        };

        home-manager-flake = lib.options.mkOption {
          default = null;
          description = ''
            The path where the `home-manager` flake is on disk.

            This should be an absolute path to the directory of the `flake.nix` file,
            not the `flake.nix` file itself.
          '';
          type = lib.types.nullOr (lib.types.either lib.types.singleLineStr lib.types.path);
        };

        nix-darwin-flake = lib.options.mkOption {
          default = null;
          description = ''
            The path where the `nix-darwin` flake is on disk.

            This should be an absolute path to the directory of the `flake.nix` file,
            not the `flake.nix` file itself.
          '';
          type = lib.types.nullOr (lib.types.either lib.types.singleLineStr lib.types.path);
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "nh" { };
      };

      nil = {
        enable = lib.options.mkEnableOption "nil" // {
          default = config.usable-nix.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "nil" { };
      };

      nix-output-monitor = {
        enable = lib.options.mkEnableOption "nix-output-monitor" // {
          default = config.usable-nix.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "nix-output-monitor" { };
      };

      nixfmt-rfc-style = {
        enable = lib.options.mkEnableOption "nixfmt-rfc-style" // {
          default = config.usable-nix.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "nixfmt-rfc-style" { };
      };
    };
  };
}
