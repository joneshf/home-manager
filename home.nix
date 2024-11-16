{ config, pkgs, ... }:

let
  git-email = "jones3.hardy@gmail.com";

  git-signing-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";

  git-username = "joneshf";

  home-directory = "/Users/${username}";

  unfreePackages = [ "1password-cli" ];

  username = "joneshf";
in

{
  # This comes from the `./modules/crane-completions` module.
  crane-completions = {
    enable = true;
  };

  # This comes from the `./modules/git-spice` module.
  git-spice = {
    enable = true;

    # Since `git-spice` only wants to make a `gs` binary available,
    # we rename to something that doesn't conflict with `Ghostscript`'s `gs` binary.
    # More things know about `Ghostscript` than `git-spice`,
    # so it gets to keep its decades old name.
    installed-binary-name = "git-spice";
  };

  home = {
    file = {
      ".ssh/allowed_signers" = {
        text = ''
          ${git-email} ${git-signing-key}
        '';
      };

      # When `home-manager` is in control of `vim`,
      # it doesn't create a `~/.vimrc` file.
      # It uses the file in the `nix` store directly without symlinking it.
      # We want a `~/.vimrc` file to exist so we don't get confused with what is giving `vim` behavior.
      # So we explicitly write out the file here.
      ".vimrc" = {
        source = ./home-files/.vimrc;
      };
    };

    # Home Manager needs a bit of information about you and the paths it should manage.
    homeDirectory = home-directory;

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.bazel
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
      pkgs.python311Packages.python-vipaccess
      pkgs.qrencode
      pkgs.tree
      pkgs.utm
      pkgs.vim
      pkgs.yarn
      pkgs.yq-go

      pkgs.unstable.difftastic
      pkgs.unstable.git-absorb
      pkgs.unstable.nixfmt-rfc-style
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
    ./modules/crane-completions
    ./modules/git-spice
    ./modules/nix-env.fish
    ./modules/pdm
    ./modules/restack
  ];

  # This comes from the `./modules/nix-env.fish` module.
  nix-env_fish = {
    enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) unfreePackages;
    };
  };

  # This comes from the `./modules/pdm` module.
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

      shellInit = ''
        set --export GPG_TTY (tty)
      '';
    };

    git = {
      enable = true;

      extraConfig = {
        commit = {
          cleanup = "scissors";

          gpgSign = true;

          verbose = true;
        };

        gpg = {
          format = "ssh";

          ssh = {
            allowedSignersFile = "${home-directory}/.ssh/allowed_signers";

            program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
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

        tag = {
          gpgSign = true;
        };

        user = {
          signingKey = git-signing-key;
        };
      };

      lfs = {
        enable = true;
      };

      userEmail = git-email;

      userName = git-username;
    };

    go = {
      enable = true;
    };

    home-manager = {
      # Let Home Manager install and manage itself.
      enable = true;
    };

    jq = {
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

  # This comes from the `./modules/restack` module.
  restack = {
    enable = true;
  };
}
