{ config, pkgs, ... }:

let
  commit-email = "jones3.hardy@gmail.com";

  commit-username = "joneshf";

  unfreePackages = [
    "1password-cli"
    "onepassword-password-manager"
    "spotify"
    "vscode"
  ];
in

{
  commit-signing = {
    enable = true;

    # this comes from the `./modules/commit-signing/module.nix` module.
    ssh = {
      email = commit-email;

      program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";

      public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";
    };
  };

  home = {
    file = {
      ".ideavimrc" = {
        source = ./home-files/.ideavimrc;
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

      # When `home-manager` is in control of `vim`,
      # it doesn't create a `~/.vimrc` file.
      # It uses the file in the `nix` store directly without symlinking it.
      # We want a `~/.vimrc` file to exist so we don't get confused with what is giving `vim` behavior.
      # So we explicitly write out the file here.
      ".vimrc" = {
        source = ./home-files/.vimrc;
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

      "Library/Application Support/jjui/config.toml" = {
        source = pkgs.writers.writeTOML "config.toml" {
          custom_commands = {
            "simplify-parents" = {
              args = [ "simplify-parents" ];
            };
          };
        };
      };
    };

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.beancount
      pkgs.crane
      pkgs.docker-credential-helpers
      pkgs.fava
      pkgs.ghostscript_headless
      pkgs.gnugrep
      pkgs.kubectl
      pkgs.kubelogin-oidc
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.open-dyslexic
      pkgs.nil
      pkgs.nixpkgs-fmt
      pkgs.nodejs_22
      pkgs.oath-toolkit
      pkgs.pdfchain
      pkgs.pdftk
      pkgs.qrencode
      pkgs.rename
      pkgs.tree
      pkgs.utm
      pkgs.vim
      pkgs.yarn
      pkgs.yq-go

      pkgs.brew-nix.arduino-ide
      pkgs.brew-nix.buckets
      pkgs.brew-nix.calibre
      pkgs.brew-nix.chromium
      pkgs.brew-nix.discord
      pkgs.brew-nix.duckduckgo
      pkgs.brew-nix.elgato-stream-deck
      pkgs.brew-nix.freecad
      pkgs.brew-nix.handbrake
      pkgs.brew-nix.jetbrains-toolbox
      pkgs.brew-nix.kicad
      pkgs.brew-nix.krita
      pkgs.brew-nix.makemkv
      pkgs.brew-nix.mqtt-explorer
      pkgs.brew-nix.obsidian
      pkgs.brew-nix.signal
      pkgs.brew-nix.turbotax-2024

      pkgs.unstable.awscli2
      pkgs.unstable.bazel_7
      pkgs.unstable.bazel-buildtools
      pkgs.unstable.bazelisk
      pkgs.unstable.colima
      pkgs.unstable.git-absorb
      pkgs.unstable.jjui
      pkgs.unstable.jnv
      pkgs.unstable.krew
      pkgs.unstable.kubernetes-helm
      pkgs.unstable.moonlight-qt
      pkgs.unstable.nix-output-monitor
      pkgs.unstable.nixfmt-rfc-style
      pkgs.unstable.nmap
      pkgs.unstable.openldap
      pkgs.unstable.openscad
      pkgs.unstable.opentofu
      pkgs.unstable.pv-migrate
      pkgs.unstable.python312Packages.python-vipaccess
      pkgs.unstable.qbittorrent
      pkgs.unstable.rectangle
      pkgs.unstable.spotify
      pkgs.unstable.uv
      pkgs.unstable.viddy
      pkgs.unstable.wireshark
      pkgs.unstable.zotero
    ];

    # Extra directories to add to PATH.
    sessionPath = [
      # Add JetBrains scripts to path
      "${config.home.homeDirectory}/Library/Application Support/JetBrains/Toolbox/scripts"
      # Add cargo bin to path
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    # Environment variables.
    sessionVariables = {
      EDITOR = "vim";

      # `nh` needs the location of the `nix-darwin` flake.
      NH_DARWIN_FLAKE = "/etc/nix-darwin";

      # `nh` needs the location of the `home-manager` flake.
      NH_HOME_FLAKE = "${config.xdg.configHome}/home-manager";

      # `fish` changed how they handle commands and keywords.
      # See https://github.com/fish-shell/fish-shell/pull/10758.
      # It's actually really nice to see them wanting to improve this sort of thing.
      # But it's a little hard to adjust to it (it feels like something is broken).
      # We revert the colors back to being `blue` for now.
      # We'll try removing these reversions at some point in the future.
      fish_color_command = "blue";

      fish_color_keyword = "blue";
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
  };

  imports = [
    ./modules/commit-signing/module.nix
    ./modules/home/home-directory-convention/module.nix
    ./modules/programs/crane/completions/module.nix
    ./modules/programs/fish/package-plugins/module.nix
    ./modules/programs/git/structural/module.nix
    ./modules/programs/git-spice/module.nix
    ./modules/programs/godot/module.nix
    ./modules/programs/pdm/module.nix
    ./modules/programs/restack/module.nix
    ./modules/targets/darwin/copy-application-bundles/module.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) unfreePackages;
    };
  };

  programs = {
    # This comes from the `_1password-shell-plugins` module.
    _1password-shell-plugins = {
      enable = true;

      plugins = [ pkgs.unstable.gh ];
    };

    bat = {
      enable = true;
    };

    # This comes from the `./modules/programs/crane/completions/module.nix` module.
    crane = {
      completions = {
        enable = true;
      };
    };

    direnv = {
      config = {
        global = {
          strict_env = true;
        };
      };

      enable = true;

      nix-direnv = {
        enable = true;
      };
    };

    firefox = {
      enable = true;

      package = pkgs.unstable.firefox;

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
          extensions = {
            packages = [
              pkgs.firefox-addons.onepassword-password-manager
              pkgs.firefox-addons.ublock-origin
            ];
          };

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

    fish = {
      # Use fish!
      enable = true;

      package = pkgs.unstable.fish;

      # This comes from the `./modules/programs/fish/package-plugins/module.nix` module.
      package-plugins = [
        (pkgs.callPackage ./packages/nix-env.fish/package.nix { })
      ];

      shellInit = ''
        set --export GPG_TTY (tty)
      '';
    };

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

      structural = {
        enable = true;

        package = pkgs.unstable.difftastic;
      };

      userEmail = commit-email;

      userName = commit-username;
    };

    # This comes from the `./modules/programs/git-spice/module.nix` module.
    git-spice = {
      enable = true;

      # Since `git-spice` only wants to make a `gs` binary available,
      # we rename to something that doesn't conflict with `Ghostscript`'s `gs` binary.
      # More things know about `Ghostscript` than `git-spice`,
      # so it gets to keep its decades old name.
      installed-binary-name = "git-spice";
    };

    go = {
      enable = true;
    };

    # This comes from the `./modules/programs/godot/module.nix` module.
    godot = {
      enable = true;
    };

    home-manager = {
      # Let Home Manager install and manage itself.
      enable = true;
    };

    jq = {
      enable = true;
    };

    jujutsu = {
      enable = true;

      package = pkgs.unstable.jujutsu;

      settings = {
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
        };

        ui = {
          merge-editor = "mergiraf";

          show-cryptographic-signatures = true;
        };

        user = {
          email = commit-email;

          name = commit-username;
        };
      };
    };

    k9s = {
      enable = true;

      package = pkgs.unstable.k9s;
    };

    man = {
      generateCaches = false;
    };

    mergiraf = {
      enable = true;

      package = pkgs.unstable.mergiraf;
    };

    nh = {
      enable = true;

      package = pkgs.unstable.nh;
    };

    numbat = {
      enable = true;

      package = pkgs.unstable.numbat;
    };

    nushell = {
      # Trying out Nushell: https://www.nushell.sh/.
      enable = true;

      extraEnv = ''
        $env.GPG_TTY = (tty)

        # Setup PEP582 for pdm
        # Unfortunately, `pdm` doesn't support `nushell`.
        # We use the output of the `fish` support to munge something out of it.
        $env.PYTHONPATH = (
          # Evaluate `pdm --pep582` in fish,
          # and return a environment-separated string.
          | ${pkgs.fish}/bin/fish --command='eval (${pkgs.pdm}/bin/pdm --pep582); echo "$PYTHONPATH"'
          # Split the string into a list based on the environment separator.
          | split row (char env_sep)
          # Remove any whitespace that might've snuck in.
          | str trim
          # Prepend the values by appending the previous values (if they exist).
          | append $env.PYTHONPATH?
          # Remove any duplicates we might've added.
          | uniq
          # Remove any blanks we might've added.
          | compact
          # Join the list back into a string with the environment separator.
          | str join (char env_sep)
        )
      '';
    };

    # This comes from the `./modules/programs/pdm/module.nix` module.
    pdm = {
      enable = true;
    };

    # This comes from the `./modules/programs/restack/module.nix` module.
    restack = {
      enable = true;
    };

    ssh = {
      enable = true;

      matchBlocks = {
        "*" = {
          extraOptions = {
            IdentityAgent = "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

            IgnoreUnknown = "UseKeychain";
          };
        };
      };
    };

    starship = {
      enable = true;

      package = pkgs.unstable.starship;

      settings = {
        battery = {
          display = [
            {
              style = "red";
              threshold = 10;
            }
            {
              style = "yellow";
              threshold = 90;
            }
            {
              style = "green";
              threshold = 100;
            }
          ];
        };

        kubernetes = {
          disabled = false;
        };
      };
    };

    vscode = {
      enable = true;

      package = pkgs.unstable.vscode;

      profiles = {
        default = {
          enableExtensionUpdateCheck = false;

          enableUpdateCheck = false;
        };

        home-manager = {
          extensions = [
            pkgs.unstable.vscode-extensions.jnoortheen.nix-ide
            pkgs.unstable.vscode-extensions.mkhl.direnv
            pkgs.unstable.vscode-extensions.vscodevim.vim

            (pkgs.unstable.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                hash = "sha256-v9oyoqqBcbFSOOyhPa4dUXjA2IVXlCTORs4nrFGSHzE=";
                name = "vscode-fileutils";
                publisher = "sleistner";
                version = "3.10.3";
              };
            })
          ];

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

  targets = {
    darwin = {
      # This comes from the `./modules/targets/darwin/copy-application-bundles/module.nix` module.
      copy-application-bundles = {
        directory = "Applications/Copied Application Bundles";

        enable = true;
      };

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

        "com.microsoft.VSCode" = {
          # Disable special character pop-up,
          # so holding a key repeats it in VS Code.
          ApplePressAndHoldEnabled = false;
        };

        "com.jetbrains.WebStorm" = {
          # Disable special character pop-up,
          # so holding a key repeats it in WebStorm.
          ApplePressAndHoldEnabled = false;
        };
      };
    };
  };
}
