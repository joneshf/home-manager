{ config, pkgs, ... }:

{
  browsers = {
    enable = true;

    chromium = {
      package = pkgs.brew-nix.chromium;
    };

    duckduckgo = {
      package = pkgs.brew-nix.duckduckgo;
    };
  };

  editors = {
    enable = true;
  };

  finance = {
    enable = true;

    buckets = {
      package = pkgs.brew-nix.buckets;
    };

    turbotax-2024 = {
      package = pkgs.brew-nix.turbotax-2024;
    };
  };

  gpg = {
    enable = true;
  };

  home = {
    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.awscli2
      pkgs.bazel_7
      pkgs.bazel-buildtools
      pkgs.bazelisk
      pkgs.colima
      pkgs.docker-credential-helpers
      pkgs.ghostscript_headless
      pkgs.gnugrep
      pkgs.go-containerregistry
      pkgs.jnv
      pkgs.krew
      pkgs.kubectl
      pkgs.kubelogin-oidc
      pkgs.kubernetes-helm
      pkgs.moonlight-qt
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.open-dyslexic
      pkgs.nixpkgs-fmt
      pkgs.nmap
      pkgs.nodejs_22
      pkgs.oath-toolkit
      pkgs.openldap
      pkgs.openscad
      pkgs.opentofu
      pkgs.pdfchain
      pkgs.pdftk
      pkgs.pv-migrate
      (pkgs.python312Packages.python-vipaccess.overridePythonAttrs {
        # The upstream derivation has out-of-date exclusions.
        # It wants to make sure no test that require network are running,
        # but the naming of tests changed in https://github.com/dlenski/python-vipaccess/commit/cc4366f7bce41d5ebce64ae8d86cc71e5eda5703.
        #
        # This is a real issue now because `pytest` 8.4.0 has turned tests with `yield` from warnings to errors: https://github.com/pytest-dev/pytest/pull/12968.
        # What this means in practice is that the tests for `python-vipaccess` cause `nix` to fail to build.
        # Worse yet,
        # `pytest` fails if it sees any tests at all with a `yield`–even if that test isn't being run.
        #
        # We disable the check phase entirely.
        # This isn't ideal,
        # but it at least gets us building again.
        checkPhase = ":";
      })
      pkgs.qbittorrent
      pkgs.qrencode
      pkgs.rename
      pkgs.tree
      pkgs.utm
      pkgs.uv
      pkgs.viddy
      pkgs.wireshark
      pkgs.yarn
      pkgs.yq-go
      pkgs.zotero

      pkgs.brew-nix.arduino-ide
      pkgs.brew-nix.calibre
      pkgs.brew-nix.discord
      pkgs.brew-nix.elgato-stream-deck
      pkgs.brew-nix.freecad
      pkgs.brew-nix.handbrake-app
      pkgs.brew-nix.kicad
      # Something about `krita` has started failing to build.
      # There are a bunch of errors that look like this:
      # ```
      #  ERROR: Dangerous link via another link was ignored : krita.app/Contents/Frameworks/libkritawidgetutils.dylib : libkritawidgetutils.19.dylib
      # ```
      # It's not clear what that error means,
      # and (more importantly) it's not clear how to fix it.
      # We don't install `krita` with `nix` for now.
      # pkgs.brew-nix.krita
      pkgs.brew-nix.makemkv
      pkgs.brew-nix.mqtt-explorer
      pkgs.brew-nix.obsidian
      pkgs.brew-nix.signal
    ];

    # Extra directories to add to PATH.
    sessionPath = [
      # Add cargo bin to path
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    # Environment variables.
    sessionVariables = {
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
    ./modules/browsers/module.nix
    ./modules/editors/module.nix
    ./modules/finance/module.nix
    ./modules/gpg/module.nix
    ./modules/home/home-directory-convention/module.nix
    ./modules/macos/module.nix
    ./modules/media/module.nix
    ./modules/nixpkgs/unfree-packages/module.nix
    ./modules/password-managers/module.nix
    ./modules/programs/fish/package-plugins/module.nix
    ./modules/programs/godot/module.nix
    ./modules/programs/pdm/module.nix
    ./modules/targets/darwin/copy-application-bundles/module.nix
    ./modules/usable-nix/module.nix
    ./modules/version-control/module.nix
  ];

  # This comes from the `./modules/macos/module.nix` module.
  macos = {
    enable = true;
  };

  # This comes from the `./modules/media/module.nix` module.
  media = {
    enable = true;
  };

  # This comes from the `./modules/password-managers/module.nix` module.
  password-managers = {
    enable = true;

    "1password" = {
      firefox = {
        profiles = [
          "home-manager"
        ];
      };

      shell-plugins = {
        packages = [ pkgs.gh ];
      };
    };
  };

  programs = {
    bat = {
      enable = true;
    };

    fish = {
      # Use fish!
      enable = true;

      # This comes from the `./modules/programs/fish/package-plugins/module.nix` module.
      package-plugins = [
        (pkgs.callPackage ./packages/nix-env.fish/package.nix { })
      ];
    };

    go = {
      enable = true;
    };

    # This comes from the `./modules/programs/godot/module.nix` module.
    godot = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    k9s = {
      enable = true;
    };

    man = {
      generateCaches = false;
    };

    numbat = {
      enable = true;
    };

    nushell = {
      # Trying out Nushell: https://www.nushell.sh/.
      enable = true;
    };

    # This comes from the `./modules/programs/pdm/module.nix` module.
    pdm = {
      enable = true;
    };

    ssh = {
      enable = true;

      enableDefaultConfig = false;

      matchBlocks = {
        # These are the default values mentioned in https://github.com/nix-community/home-manager/commit/77a71380c38fb2a440b4b5881bbc839f6230e1cb.
        "*" = {
          addKeysToAgent = "no";

          compression = false;

          controlMaster = "no";

          controlPath = "~/.ssh/master-%r@%n:%p";

          forwardAgent = false;

          hashKnownHosts = false;

          serverAliveCountMax = 3;

          serverAliveInterval = 0;

          userKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
    };

    starship = {
      enable = true;

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
  };

  usable-nix = {
    enable = true;

    nh = {
      # `nh` needs the location of the `home-manager` flake.
      home-manager-flake = "${config.xdg.configHome}/home-manager";

      # `nh` needs the location of the `nix-darwin` flake.
      nix-darwin-flake = "/etc/nix-darwin";
    };
  };

  version-control = {
    email = "jones3.hardy@gmail.com";

    enable = true;

    jujutsu = {
      jjui = {
        package = pkgs.jjui.jjui;
      };
    };

    ssh-public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";

    username = "joneshf";
  };
}
