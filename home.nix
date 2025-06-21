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

  home = {
    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.awscli2
      pkgs.bazel_7
      pkgs.bazel-buildtools
      pkgs.bazelisk
      pkgs.beancount
      pkgs.colima
      pkgs.docker-credential-helpers
      pkgs.fava
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
      pkgs.nil
      pkgs.nix-output-monitor
      pkgs.nixfmt-rfc-style
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
      pkgs.python312Packages.python-vipaccess
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
      pkgs.brew-nix.buckets
      pkgs.brew-nix.calibre
      pkgs.brew-nix.discord
      pkgs.brew-nix.elgato-stream-deck
      pkgs.brew-nix.freecad
      pkgs.brew-nix.handbrake
      pkgs.brew-nix.kicad
      pkgs.brew-nix.krita
      pkgs.brew-nix.makemkv
      pkgs.brew-nix.mqtt-explorer
      pkgs.brew-nix.obsidian
      pkgs.brew-nix.signal
      pkgs.brew-nix.turbotax-2024
    ];

    # Extra directories to add to PATH.
    sessionPath = [
      # Add cargo bin to path
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    # Environment variables.
    sessionVariables = {
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
    ./modules/browsers/module.nix
    ./modules/editors/module.nix
    ./modules/home/home-directory-convention/module.nix
    ./modules/macos/module.nix
    ./modules/media/module.nix
    ./modules/nixpkgs/unfree-packages/module.nix
    ./modules/password-managers/module.nix
    ./modules/programs/fish/package-plugins/module.nix
    ./modules/programs/godot/module.nix
    ./modules/programs/pdm/module.nix
    ./modules/targets/darwin/copy-application-bundles/module.nix
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

    fish = {
      # Use fish!
      enable = true;

      # This comes from the `./modules/programs/fish/package-plugins/module.nix` module.
      package-plugins = [
        (pkgs.callPackage ./packages/nix-env.fish/package.nix { })
      ];

      shellInit = ''
        set --export GPG_TTY (tty)
      '';
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

    k9s = {
      enable = true;
    };

    man = {
      generateCaches = false;
    };

    nh = {
      enable = true;
    };

    numbat = {
      enable = true;
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

    ssh = {
      enable = true;
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

  version-control = {
    email = "jones3.hardy@gmail.com";

    enable = true;

    ssh-public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";

    username = "joneshf";
  };
}
