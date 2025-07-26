{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.editors.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.editors.jetbrains.enable (
        lib.modules.mkMerge [
          {
            home = {
              file = {
                ".ideavimrc" = {
                  source = ../../home-files/.ideavimrc;
                };

                ".intellimacs" = {
                  recursive = true;

                  source = pkgs.fetchFromGitHub {
                    owner = "MarcoIeni";

                    repo = "intellimacs";

                    rev = "cf9706cfeaf18e2247ee8f8c8289f1d196ce04b9";

                    sha256 = "sha256-uANOwkA9EB3n1Kd+55420LJD7wrc4EDQ7z127HLvM2o=";
                  };
                };
              };
            };
          }

          (lib.modules.mkIf config.editors.jetbrains.jetbrains-toolbox.enable (
            lib.modules.mkMerge [
              {
                home = {
                  packages = [
                    config.editors.jetbrains.jetbrains-toolbox.package
                  ];
                };

                nixpkgs = {
                  # This comes from the `../nixpkgs/unfree-packages/module.nix` module.
                  unfree-packages = {
                    allow = [
                      (lib.strings.getName config.editors.jetbrains.jetbrains-toolbox.package)
                    ];

                    enable = true;
                  };
                };
              }

              (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
                home = {
                  sessionPath = [
                    # Add JetBrains scripts to path
                    "${config.home.homeDirectory}/Library/Application Support/JetBrains/Toolbox/scripts"
                  ];
                };
              })
            ]
          ))

          (lib.modules.mkIf config.editors.jetbrains.webstorm.enable (
            lib.modules.mkMerge [
              (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
                targets = {
                  darwin = {
                    defaults = {
                      "com.jetbrains.WebStorm" = {
                        # Disable special character pop-up,
                        # so holding a key repeats it in WebStorm.
                        ApplePressAndHoldEnabled = false;
                      };
                    };
                  };
                };
              })
            ]
          ))
        ]
      ))

      (lib.modules.mkIf config.editors.vim.enable (
        lib.modules.mkMerge [
          {
            home = {
              file = {
                # When `home-manager` is in control of `vim`,
                # it doesn't create a `~/.vimrc` file.
                # It uses the file in the `nix` store directly without symlinking it.
                # We want a `~/.vimrc` file to exist so we don't get confused with what is giving `vim` behavior.
                # So we explicitly write out the file here.
                ".vimrc" = {
                  source = ../../home-files/.vimrc;
                };

                ".vim/autoload/plug.vim" = {
                  source =
                    let
                      src = pkgs.fetchFromGitHub {
                        owner = "junegunn";

                        repo = "vim-plug";

                        rev = "d80f495fabff8446972b8695ba251ca636a047b0";

                        sha256 = "sha256-d8LZYiJzAOtWGIXUJ7788SnJj44nhdZB0mT5QW3itAY=";
                      };

                    in
                    "${src}/plug.vim";
                };
              };

              packages = [
                pkgs.vim
              ];

              sessionVariables = {
                EDITOR = "vim";
              };
            };
          }
        ]
      ))

      (lib.modules.mkIf config.editors.vscode.enable (
        lib.modules.mkMerge [
          {
            nixpkgs = {
              # This comes from the `../nixpkgs/unfree-packages/module.nix` module.
              unfree-packages = {
                allow = [
                  (lib.strings.getName config.editors.vscode.package)
                ];

                enable = true;
              };
            };

            programs = {
              vscode = {
                enable = true;

                package = config.editors.vscode.package;

                profiles = {
                  default = {
                    enableExtensionUpdateCheck = false;

                    enableUpdateCheck = false;
                  };

                  home-manager = {
                    userSettings = {
                      # Different key bindings will ask to turn on screen reader support.
                      # We explicitly set it to `"off"` so VSCode doesn't pop up a modal at random times.
                      "editor.accessibilitySupport" = "off";
                      "editor.cursorBlinking" = "expand";
                      "editor.cursorStyle" = "line";
                      "editor.formatOnPaste" = true;
                      "editor.formatOnSave" = true;
                      "editor.renderWhitespace" = "all";
                      "editor.rulers" = [ 80 ];
                      "editor.wordWrap" = "off";
                      "files.insertFinalNewline" = true;
                      "files.trimFinalNewlines" = true;
                      "files.trimTrailingWhitespace" = true;
                      "nix.enableLanguageServer" = true;
                      "purescript.addNpmPath" = true;
                      "window.autoDetectColorScheme" = true;
                      "window.zoomLevel" = 2;
                      "workbench.editor.highlightModifiedTabs" = true;
                      "workbench.preferredDarkColorTheme" = "Solarized Dark";
                      "workbench.preferredLightColorTheme" = "Solarized Light";
                    };
                  };
                };
              };
            };
          }

          (lib.modules.mkIf config.editors.vscode.extensions.golang.Go.enable {
            programs = {
              vscode = {
                profiles = {
                  home-manager = {
                    extensions = [
                      config.editors.vscode.extensions.golang.Go.package
                    ];
                  };
                };
              };
            };
          })

          (lib.modules.mkIf config.editors.vscode.extensions.jnoortheen.nix-ide.enable {
            programs = {
              vscode = {
                profiles = {
                  home-manager = {
                    extensions = [
                      config.editors.vscode.extensions.jnoortheen.nix-ide.package
                    ];
                  };
                };
              };
            };
          })

          (lib.modules.mkIf config.editors.vscode.extensions.mkhl.direnv.enable {
            programs = {
              vscode = {
                profiles = {
                  home-manager = {
                    extensions = [
                      config.editors.vscode.extensions.mkhl.direnv.package
                    ];
                  };
                };
              };
            };
          })

          (lib.modules.mkIf config.editors.vscode.extensions.sleistner.vscode-fileutils.enable {
            programs = {
              vscode = {
                profiles = {
                  home-manager = {
                    extensions = [
                      config.editors.vscode.extensions.sleistner.vscode-fileutils.package
                    ];
                  };
                };
              };
            };
          })

          (lib.modules.mkIf config.editors.vscode.extensions.vscodevim.vim.enable {
            programs = {
              vscode = {
                profiles = {
                  home-manager = {
                    extensions = [
                      config.editors.vscode.extensions.vscodevim.vim.package
                    ];
                  };
                };
              };
            };
          })

          (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            targets = {
              darwin = {
                defaults = {
                  "com.microsoft.VSCode" = {
                    # Disable special character pop-up,
                    # so holding a key repeats it in VS Code.
                    ApplePressAndHoldEnabled = false;
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
    ../nixpkgs/unfree-packages/module.nix
  ];

  options = {
    editors = {
      enable = lib.options.mkEnableOption "editors";

      jetbrains = {
        enable = lib.options.mkEnableOption "JetBrains editors" // {
          default = config.editors.enable;
        };

        jetbrains-toolbox = {
          enable = lib.options.mkEnableOption "JetBrains Toolbox" // {
            default = config.editors.jetbrains.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "jetbrains-toolbox" { };
        };

        webstorm = {
          enable = lib.options.mkEnableOption "WebStorm" // {
            default = config.editors.jetbrains.enable;
          };
        };
      };

      vim = {
        enable = lib.options.mkEnableOption "Vim" // {
          default = config.editors.enable;
        };
      };

      vscode = {
        enable = lib.options.mkEnableOption "VS Code" // {
          default = config.editors.enable;
        };

        extensions = {
          golang = {
            Go = {
              enable = lib.options.mkEnableOption "golang.Go extension" // {
                default = config.editors.vscode.enable;
              };

              package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
                "vscode-extensions"
                "golang"
                "go"
              ] { };
            };
          };

          jnoortheen = {
            nix-ide = {
              enable = lib.options.mkEnableOption "jnoortheen.nix-ide extension" // {
                default = config.editors.vscode.enable;
              };
              package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
                "vscode-extensions"
                "jnoortheen"
                "nix-ide"
              ] { };
            };
          };

          mkhl = {
            direnv = {
              enable = lib.options.mkEnableOption "mkhl.direnv extension" // {
                default = config.editors.vscode.enable;
              };
              package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
                "vscode-extensions"
                "mkhl"
                "direnv"
              ] { };
            };
          };

          sleistner = {
            vscode-fileutils = {
              enable = lib.options.mkEnableOption "sleistner.vscode-fileutils extension" // {
                default = config.editors.vscode.enable;
              };
              package =
                pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs
                  [
                    "vscode-extensions"
                    "sleistner"
                    "vscode-fileutils"
                  ]
                  {
                    default = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
                      mktplcRef = {
                        hash = "sha256-v9oyoqqBcbFSOOyhPa4dUXjA2IVXlCTORs4nrFGSHzE=";
                        name = "vscode-fileutils";
                        publisher = "sleistner";
                        version = "3.10.3";
                      };
                    };
                  };
            };
          };

          vscodevim = {
            vim = {
              enable = lib.options.mkEnableOption "vscodevim.vim extension" // {
                default = config.editors.vscode.enable;
              };
              package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
                "vscode-extensions"
                "vscodevim"
                "vim"
              ] { };
            };
          };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "vscode" { };
      };
    };
  };
}
