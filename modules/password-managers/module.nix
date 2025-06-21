{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.password-managers.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.password-managers."1password".enable (
        lib.modules.mkMerge [
          {
            nixpkgs = {
              # This comes from the `../nixpkgs/unfree-packages/module.nix` module.
              unfree-packages = {
                allow = [
                  "1password-cli"
                ];

                enable = true;
              };
            };
          }

          (lib.modules.mkIf config.password-managers."1password".firefox.enable {
            nixpkgs = {
              # This comes from the `../nixpkgs/unfree-packages/module.nix` module.
              unfree-packages = {
                allow = [
                  "onepassword-password-manager"
                ];

                enable = true;
              };
            };

            programs = {
              firefox = {
                profiles = lib.attrsets.genAttrs config.password-managers."1password".firefox.profiles (_profile: {
                  extensions = {
                    packages = [
                      config.password-managers."1password".firefox.extension-package
                    ];
                  };
                });
              };
            };
          })

          (lib.modules.mkIf config.password-managers."1password".commit-signing.enable {
            # This comes from the `../commit-signing/module.nix` module.
            commit-signing = {
              ssh = {
                program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
              };
            };
          })

          (lib.modules.mkIf config.password-managers."1password".shell-plugins.enable {
            programs = {
              # This comes from the `_1password-shell-plugins` module.
              _1password-shell-plugins = {
                enable = true;

                plugins = config.password-managers."1password".shell-plugins.packages;
              };
            };
          })

          (lib.modules.mkIf config.password-managers."1password".ssh.enable {
            programs = {
              ssh = {
                matchBlocks = {
                  "*" = {
                    extraOptions = {
                      IdentityAgent = "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

                      IgnoreUnknown = "UseKeychain";
                    };
                  };
                };
              };
            };
          })
        ]
      ))
    ]
  );

  imports = [
    ../commit-signing/module.nix
    ../nixpkgs/unfree-packages/module.nix
  ];

  options = {
    password-managers = {
      enable = lib.options.mkEnableOption "password manager";

      "1password" = {
        commit-signing = {
          enable = lib.options.mkEnableOption "commit signing integration" // {
            default = config.password-managers."1password".enable && config.commit-signing.enable;
          };
        };

        enable = lib.options.mkEnableOption "1Password" // {
          default = config.password-managers.enable;
        };

        firefox = {
          enable = lib.options.mkEnableOption "Firefox integration" // {
            default = config.password-managers."1password".enable && config.programs.firefox.enable;
          };

          extension-package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
            "firefox-addons"
            "onepassword-password-manager"
          ] { };

          profiles = lib.options.mkOption {
            default = [ ];
            description = "Firefox profiles to enable the 1Password extension";
            type = lib.types.listOf lib.types.str;
          };
        };

        shell-plugins = {
          enable = lib.options.mkEnableOption "shell plugins" // {
            default = config.password-managers."1password".enable;
          };

          packages = lib.options.mkOption {
            default = [ ];
            description = "The set of packages to enable 1Password shell plugins.";
            type = lib.types.listOf lib.types.package;
          };
        };

        ssh = {
          enable = lib.options.mkEnableOption "SSH integration" // {
            default = config.password-managers."1password".enable && config.programs.ssh.enable;
          };
        };
      };
    };
  };
}
