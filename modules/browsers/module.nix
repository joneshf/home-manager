{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.browsers.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.browsers.chromium.enable {
        home = {
          packages = [
            config.browsers.chromium.package
          ];
        };
      })

      (lib.modules.mkIf config.browsers.duckduckgo.enable {
        home = {
          packages = [
            config.browsers.duckduckgo.package
          ];
        };
      })

      (lib.modules.mkIf config.browsers.firefox.enable (
        lib.modules.mkMerge [
          {
            programs = {
              firefox = {
                enable = true;

                package = config.browsers.firefox.package;

                policies = {
                  DisableTelemetry = true;

                  EnableTrackingProtection = {
                    Cryptomining = true;

                    EmailTracking = true;

                    Fingerprinting = true;

                    Value = true;
                  };

                  FirefoxSuggest = {
                    ImproveSuggest = false;

                    Locked = true;

                    SponsoredSuggestions = false;

                    WebSuggestions = false;
                  };

                  SearchEngines = {
                    Remove = [
                      "Amazon.com"
                      "Bing"
                      "Google"
                      "eBay"
                    ];
                  };

                  SearchSuggestEnabled = false;
                };

                profiles = {
                  home-manager = {
                    search = {
                      default = "ddg";

                      force = true;
                    };

                    settings = {
                      # `3` checks the box for "General > Startup > Open previous windows and tabs"
                      "browser.startup.page" = 3;

                      # Allow extensions to be auto-enabled
                      "extensions.autoDisableScopes" = 0;

                      "extensions.update.autoUpdateDefault" = false;

                      "extensions.update.enabled" = false;
                    };
                  };
                };
              };
            };
          }

          (lib.modules.mkIf config.browsers.firefox.extensions.ublock-origin.enable {
            programs = {
              firefox = {
                profiles = {
                  home-manager = {
                    extensions = {
                      packages = [
                        config.browsers.firefox.extensions.ublock-origin.package
                      ];
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
    ../nixpkgs/unfree-packages/module.nix
  ];

  options = {
    browsers = {
      enable = lib.options.mkEnableOption "browsers";

      chromium = {
        enable = lib.options.mkEnableOption "Chromium" // {
          default = config.browsers.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "chromium" { };
      };

      duckduckgo = {
        enable = lib.options.mkEnableOption "DuckDuckGo" // {
          default = config.browsers.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "duckduckgo" { };
      };

      firefox = {
        enable = lib.options.mkEnableOption "Firefox" // {
          default = config.browsers.enable;
        };

        extensions = {
          ublock-origin = {
            enable = lib.options.mkEnableOption "uBlock Origin extension" // {
              default = config.browsers.firefox.enable;
            };

            package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs [
              "firefox-addons"
              "ublock-origin"
            ] { };
          };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "firefox" { };
      };
    };
  };
}
