{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf (pkgs.stdenv.hostPlatform.isDarwin && config.macos.enable) (
    lib.modules.mkMerge [
      {
        targets = {
          darwin = {
            defaults = {
              NSGlobalDomain = {
                AppleICUForce24HourTime = true;
              };

              "com.apple.ActivityMonitor" = {
                IconType = 6;
              };

              "com.apple.Terminal" = {
                "Default Window Settings" = "Pro";

                "Startup Window Settings" = "Pro";

                # As nice as it would be to only set a couple of things in `"Window Settings"` (like for the `Pro` profile),
                # `home-manager` doesn't merge the `dict`s (it overwrites them).
                # And since these `dict`s contain `data` fields that `nixpkgs` doesn't support,
                # we cannot even write them in their entirety.
                # If we do,
                # they get overwritten each time `Terminal.app` starts because they're invalid.
              };

              "com.apple.assistant.support" = {
                "Search Queries Data Sharing Status" = 2;

                "Siri Data Sharing Opt-In Status" = 2;
              };

              # The settings under "Control Center > Control Center Modules" (e.g. "Bluetooth" or "Wi-Fi") are enums.
              # It's not clear what the values are,
              # and finding documentation for mac is nigh-impossible.
              #
              # After much trial and error and searching through too many web pages,
              # it seems that on older versions of macOS the values seem to be:
              # - 18: Show in Menu Bar
              # - 24: Don't Show in Menu Bar
              #
              # On newer versions of macOS the values seem to be:
              # - 2: Show in Menu Bar
              # - 8: Don't Show in Menu Bar
              #
              # We're going with the 18/24 version,
              # since that seems safer.
              # We might have to change that though.
              "com.apple.controlcenter" = {
                BatteryShowPercentage = true;

                Bluetooth = 18;
              };

              "com.apple.dock" = {
                autohide = true;

                largesize = 128;

                magnification = true;

                persistent-apps = [
                  {
                    tile-data = {
                      file-data = {
                        _CFURLString = "file://${config.home.homeDirectory}/${config.targets.darwin.copy-application-bundles.directory}/DuckDuckGo.app";

                        _CFURLStringType = 15;
                      };
                    };

                    tile-type = "file-tile";
                  }
                  {
                    tile-data = {
                      file-data = {
                        _CFURLString = "file://${config.home.homeDirectory}/${config.targets.darwin.copy-application-bundles.directory}/Signal.app";

                        _CFURLStringType = 15;
                      };
                    };

                    tile-type = "file-tile";
                  }
                  {
                    tile-data = {
                      file-data = {
                        _CFURLString = "file:///System/Applications/Utilities/Terminal.app";

                        _CFURLStringType = 15;
                      };
                    };

                    tile-type = "file-tile";
                  }
                  {
                    tile-data = {
                      file-data = {
                        _CFURLString = "file:///${config.home.homeDirectory}/${config.targets.darwin.copy-application-bundles.directory}/Visual Studio Code.app";

                        _CFURLStringType = 15;
                      };
                    };

                    tile-type = "file-tile";
                  }
                  {
                    tile-data = {
                      file-data = {
                        _CFURLString = "file:///Applications/1Password.app";

                        _CFURLStringType = 15;
                      };
                    };

                    tile-type = "file-tile";
                  }
                ];

                show-recents = false;

                tilesize = 128;
              };

              "com.apple.finder" = {
                AppleShowAllFiles = false;
              };

              "com.apple.menuextra.clock" = {
                FlashDateSeparators = true;

                ShowAMPM = false;

                ShowSeconds = true;
              };

              "com.apple.universalaccess.plist" = {
                # This is the setting for "Accessibility > Zoom > Use keyboard shortcuts to zoom".
                closeViewHotkeysEnabled = true;

                # This is the setting for "Accessibility > Zoom > Advanced… > Zoomed image moves".
                closeViewPanningMode = 2;

                # This is the setting for "Accessibility > Zoom > Advanced… > Modifiers for Temporary Actions > Toggle zoom".
                closeViewPressOnReleaseOff = true;

                # This is the setting for "Accessibility > Zoom > Zoom style".
                closeViewZoomMode = 1;
              };
            };
          };
        };
      }

      (lib.modules.mkIf config.macos.copy-application-bundles.enable {
        targets = {
          darwin = {
            # This comes from the `../targets/darwin/copy-application-bundles/module.nix` module.
            copy-application-bundles = {
              directory = "Applications/Copied Application Bundles";

              enable = true;
            };
          };
        };
      })

      (lib.modules.mkIf config.macos.rectangle.enable {
        home = {
          packages = [
            config.macos.rectangle.package
          ];
        };
      })
    ]
  );

  imports = [
    ../targets/darwin/copy-application-bundles/module.nix
  ];

  options = {
    macos = {
      copy-application-bundles = {
        enable = lib.options.mkEnableOption "copy Application Bundles with symlinked `Contents`" // {
          default = config.macos.enable;
        };
      };

      enable = lib.options.mkEnableOption "macOS setup";

      rectangle = {
        enable = lib.options.mkEnableOption "Rectangle window manager" // {
          default = config.macos.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "rectangle" { };
      };
    };
  };
}
