{ config, pkgs, ... }:

let
  git-email = "jones3.hardy@gmail.com";

  git-username = "joneshf";

  home-directory = "/Users/${username}";

  unfreePackages = [
    "1password-cli"
    "spotify"
  ];

  username = "joneshf";
in

{
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
    };

    # Home Manager needs a bit of information about you and the paths it should manage.
    homeDirectory = home-directory;

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
      (pkgs.nerdfonts.override {
        fonts = [
          "FiraCode"
          "OpenDyslexic"
        ];
      })
      pkgs.nil
      pkgs.nixpkgs-fmt
      pkgs.nodejs_20
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
      pkgs.brew-nix.firefox
      pkgs.brew-nix.freecad
      pkgs.brew-nix.handbrake
      pkgs.brew-nix.jetbrains-toolbox
      pkgs.brew-nix.kicad
      pkgs.brew-nix.krita
      pkgs.brew-nix.makemkv
      pkgs.brew-nix.mqtt-explorer
      pkgs.brew-nix.obsidian

      pkgs.unstable.awscli2
      pkgs.unstable.bazel_7
      pkgs.unstable.colima
      pkgs.unstable.difftastic
      pkgs.unstable.git-absorb
      pkgs.unstable.jnv
      pkgs.unstable.k9s
      pkgs.unstable.krew
      pkgs.unstable.kubernetes-helm
      pkgs.unstable.moonlight-qt
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
      pkgs.unstable.viddy
      pkgs.unstable.wireshark
      pkgs.unstable.zotero
    ];

    # Extra directories to add to PATH.
    sessionPath = [
      # Add JetBrains scripts to path
      "${home-directory}/Library/Application Support/JetBrains/Toolbox/scripts"
      # Add cargo bin to path
      "${home-directory}/.cargo/bin"
    ];

    # Environment variables.
    sessionVariables = {
      EDITOR = "vim";
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.

    inherit username;
  };

  imports = [
    ./modules/pdm/module.nix
    ./modules/programs/crane/completions/module.nix
    ./modules/programs/fish/package-plugins/nix-env.fish/module.nix
    ./modules/programs/git/ssh-signing/module.nix
    ./modules/programs/git-spice/module.nix
    ./modules/programs/godot/module.nix
    ./modules/restack/module.nix
    ./modules/targets/darwin/copy-application-bundles/module.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) unfreePackages;
    };
  };

  # This comes from the `./modules/pdm/module.nix` module.
  pdm = {
    enable = true;
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

    fish = {
      # Use fish!
      enable = true;

      package-plugins = {
        # This comes from the `./modules/programs/fish/package-plugins/nix-env.fish/module.nix` module.
        "nix-env.fish" = {
          enable = true;
        };
      };

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
          sslCAInfo = "${home-directory}/.ca-bundle.crt";
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

      # this comes from the `./modules/programs/git/ssh-signing/module.nix` module.
      ssh-signing = {
        email = git-email;

        enable = true;

        public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";
      };

      userEmail = git-email;

      userName = git-username;
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

    man = {
      generateCaches = false;
    };

    nh = {
      enable = true;

      # `nh` needs the location of the Home Manager flake.
      flake = "${config.xdg.configHome}/home-manager";

      package = pkgs.unstable.nh;
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

    ssh = {
      enable = true;

      matchBlocks = {
        "*" = {
          extraOptions = {
            IdentityAgent = "\"${home-directory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

            IgnoreUnknown = "UseKeychain";
          };
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

  # This comes from the `./modules/restack/module.nix` module.
  restack = {
    enable = true;
  };

  targets = {
    darwin = {
      # This comes from the `./modules/targets/darwin/copy-application-bundles/module.nix` module.
      copy-application-bundles = {
        directory = "Applications/Copied Application Bundles";
      };

      defaults = {
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
