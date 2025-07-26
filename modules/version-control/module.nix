{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.version-control.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.version-control.commit-signing.enable {
        # This comes from the `../commit-signing/module.nix` module.
        commit-signing = {
          enable = true;

          ssh = {
            email = config.version-control.email;

            public-key = config.version-control.ssh-public-key;
          };
        };
      })

      (lib.modules.mkIf config.version-control.git.enable (
        lib.modules.mkMerge [
          {
            programs = {
              git = {
                enable = true;

                extraConfig = {
                  commit = {
                    cleanup = "scissors";

                    verbose = true;
                  };

                  help = {
                    autocorrect = 1;
                  };

                  http = {
                    sslCAInfo = "${config.home.homeDirectory}/.ca-bundle.crt";
                  };

                  init = {
                    defaultBranch = "main";
                  };

                  log = {
                    format = "fuller";
                  };

                  merge = {
                    conflictStyle = "diff3";
                  };
                };

                lfs = {
                  enable = true;
                };

                userEmail = config.version-control.email;

                userName = config.version-control.username;
              };
            };
          }

          (lib.modules.mkIf config.version-control.git.git-absorb.enable {
            home = {
              packages = [
                config.version-control.git.git-absorb.package
              ];
            };
          })

          (lib.modules.mkIf config.version-control.git.git-spice.enable {
            programs = {
              # This comes from the `../programs/git-spice/module.nix` module.
              git-spice = {
                enable = true;

                # Since `git-spice` only wants to make a `gs` binary available,
                # we rename to something that doesn't conflict with `Ghostscript`'s `gs` binary.
                # More things know about `Ghostscript` than `git-spice`,
                # so it gets to keep its decades old name.
                installed-binary-name = "git-spice";
              };
            };
          })

          (lib.modules.mkIf config.version-control.git.restack.enable {
            programs = {
              # This comes from the `../programs/restack/module.nix` module.
              restack = {
                enable = true;

                package = config.version-control.git.restack.package;
              };
            };
          })

          (lib.modules.mkIf config.version-control.git.structural.enable {
            programs = {
              git = {
                structural = {
                  enable = true;

                  package = config.version-control.git.structural.package;
                };
              };
            };
          })
        ]
      ))

      (lib.modules.mkIf config.version-control.jujutsu.enable (
        lib.modules.mkMerge [
          {
            programs = {
              jujutsu = {
                enable = true;

                package = config.version-control.jujutsu.package;

                settings = {
                  git = {
                    private-commits = "private()";
                  };

                  revset-aliases = {
                    "private()" = "description(regex:'^\\[PRIVATE\\].*')";
                  };

                  template-aliases = {
                    # The suffix is everything after any prefix that might exist.
                    # All non-word characters are replaced with `-`s,
                    # and then cleaned up:
                    # - No consecutive `-`s.
                    # - No `-`s at the start or end.
                    "first_line_suffix(description)" = ''
                      description
                        .first_line()
                        .remove_prefix(jira_issue_prefix(description))
                        .remove_prefix(team_name_prefix(description))
                        .lower()
                        .replace(regex:"[[:^word:]]", "-")
                        .replace(regex:"-+", "-")
                        .replace(regex:"^-|-$", "")
                    '';

                    # Jira Issues look like `VGI-171`.
                    "jira_issue_prefix(description)" = ''
                      description
                        .match(regex:"^[[:upper:]]+-[[:digit:]]+[[:blank:]]+")
                        .replace(regex:"[[:blank:]]+", "")
                    '';

                    # Team names by convention are all caps.
                    # E.g. `REBELS`.
                    "team_name_prefix(description)" = ''
                      description
                        .match(regex:"^[[:upper:]]+[[:blank:]]+")
                        .replace(regex:"[[:blank:]]+", "")
                    '';

                    bookmark_user_namespace = "'${config.version-control.jujutsu.bookmark-user-namespace}'";
                  };

                  templates = {
                    draft_commit_description = ''
                      concat(
                        coalesce(description, default_commit_description, "\n"),
                        surround(
                          "\nJJ: This commit contains the following changes:\n",
                          "",
                          indent("JJ:     ", diff.stat(72)),
                        ),
                        "\nJJ: ignore-rest\n",
                        diff.git(),
                      )
                    '';

                    # GitHub does not support branch names longer than 244 bytes: https://stackoverflow.com/a/77347494.
                    git_push_bookmark = ''
                      truncate_end(
                        244,
                        separate(
                          "/",
                          bookmark_user_namespace,
                          coalesce(
                            jira_issue_prefix(description),
                            team_name_prefix(description),
                          ),
                          first_line_suffix(description),
                        ),
                      )
                    '';
                  };

                  ui = {
                    show-cryptographic-signatures = true;
                  };

                  user = {
                    email = config.version-control.email;

                    name = config.version-control.username;
                  };
                };
              };
            };
          }

          (lib.modules.mkIf config.version-control.jujutsu.jjui.enable (
            lib.modules.mkMerge [
              {
                home = {
                  packages = [
                    config.version-control.jujutsu.jjui.package
                  ];
                };
              }

              (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
                home = {
                  file = {
                    "Library/Application Support/jjui/config.toml" = {
                      source = pkgs.writers.writeTOML "config.toml" {
                        custom_commands = {
                          "simplify-parents" = {
                            args = [ "simplify-parents" ];
                          };
                        };

                        ui = {
                          tracer = {
                            enabled = true;
                          };
                        };
                      };
                    };
                  };
                };
              })
            ]
          ))
        ]
      ))

      (lib.modules.mkIf config.version-control.mergiraf.enable (
        lib.modules.mkMerge [
          {
            programs = {
              mergiraf = {
                enable = true;

                package = config.version-control.mergiraf.package;
              };
            };
          }

          # `home-manager` will hopefully add support for this in the `programs.mergiraf` module upstream.
          # We can ditch this part if they do that.
          (lib.modules.mkIf config.version-control.jujutsu.enable {
            programs = {
              jujutsu = {
                settings = {
                  ui = {
                    merge-editor = "mergiraf";
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
    ../programs/git/structural/module.nix
    ../programs/git-spice/module.nix
    ../programs/restack/module.nix
  ];

  options = {
    version-control = {
      email = lib.options.mkOption {
        default = null;
        description = "The email to use when making commits.";
        type = lib.types.str;
      };

      enable = lib.options.mkEnableOption "version control setup";

      commit-signing = {
        enable = lib.options.mkEnableOption "commit signing" // {
          default = config.version-control.enable;
        };
      };

      git = {
        enable = lib.options.mkEnableOption "git" // {
          default = config.version-control.enable;
        };

        git-absorb = {
          enable = lib.options.mkEnableOption "git-absorb" // {
            default = config.version-control.git.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "git-absorb" { };
        };

        git-spice = {
          enable = lib.options.mkEnableOption "git-spice" // {
            default = config.version-control.git.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "git-spice" {
            default = pkgs.callPackage ../../packages/git-spice/package.nix { };
          };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "git" { };

        restack = {
          enable = lib.options.mkEnableOption "restack" // {
            default = config.version-control.git.enable;
          };

          git-restack = {
            enable = lib.options.mkEnableOption "git-restack" // {
              default = config.version-control.git.restack.enable;
            };

            package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "git-restack" {
              default = pkgs.callPackage ../../packages/git-restack/package.nix { };
            };
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "restack" {
            default = pkgs.callPackage ../../packages/restack/package.nix { };
          };
        };

        structural = {
          enable = lib.options.mkEnableOption "git structural" // {
            default = config.version-control.git.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "difftastic" { };
        };
      };

      jujutsu = {
        bookmark-user-namespace = lib.options.mkOption {
          default = config.version-control.username;
          description = "The prefix to use to prefix bookmarks into a \"namespace\".";
          type = lib.types.str;
        };

        enable = lib.options.mkEnableOption "jujutsu" // {
          default = config.version-control.enable;
        };

        jjui = {
          enable = lib.options.mkEnableOption "jjui" // {
            default = config.version-control.jujutsu.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "jjui" { };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "jujutsu" { };
      };

      mergiraf = {
        enable = lib.options.mkEnableOption "mergiraf" // {
          default = config.version-control.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "mergiraf" { };
      };

      ssh-public-key = lib.options.mkOption {
        description = "The key to use for signing.";
        example = "ssh-ed25519 dead+beef+";
        type = lib.types.str;
      };

      username = lib.options.mkOption {
        default = null;
        description = "The username to use when making commits.";
        type = lib.types.str;
      };
    };
  };
}
