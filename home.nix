{ config
, pkgs
, ...
}:

let
  home-directory = "/Users/${username}";

  unfreePackages = [
    "1password-cli"
  ];

  username = "joneshf";
in

{
  # This comes from the `./modules/crane-completions` module.
  crane-completions = {
    enable = true;
  };

  home = {
    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';

      ".ssh/allowed_signers" = {
        text = ''
          jones3.hardy@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH
        '';
      };

      # When `home-manager` is in control of `vim`,
      # it doesn't create a `~/.vimrc` file.
      # It uses the file in the `nix` store directly without symlinking it.
      # We want a `~/.vimrc` file to exist so we don't get confused with what is giving `vim` behavior.
      # So we explicitly write out the file here.
      ".vimrc" = {
        text = ''
          set number
          syntax enable

          set autoindent
          set smartindent

          set expandtab
          set shiftwidth=4
          set smarttab
          set tabstop=4

          " git
          autocmd FileType gitcommit set textwidth=72
          highlight def link gitcommitOverflow Error

          " Makefile
          autocmd FileType make set noexpandtab
        '';
      };

      # "Library/Application Support/nushell/login.nu" = {
      #   text = ''
      #     # The `nix` environment isn't setup properly for `nushell`.
      #     # We add some environment variables that seem like they're going to do the right thing.
      #     $env.NIX_LINK_NEW = '${home-directory}/.local/state/nix/profile'
      #     $env.NIX_PROFILES = '/nix/var/nix/profiles/default ${home-directory}/.nix-profile'
      #     $env.NIX_SSL_CERT_FILE = '/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt'

      #     # We add some paths so binaries are found.
      #     $env.PATH = (
      #       # The PATH starts out as a list.
      #       | $env.PATH
      #       # If any of the values happen to have separators in them,
      #       # we want to flatten them down to be part of the list.
      #       | split row (char esep)
      #       # Prepend the binaries we want to have higher precedence than the builtins.
      #       | prepend [
      #           '${home-directory}/.nix-profile/bin'
      #           '/nix/var/nix/profiles/default/bin'
      #           '/usr/local/bin'
      #         ]
      #       # Append other binaries that we want a lower precedence for.
      #       | append [
      #           '/usr/sbin'
      #           '/sbin'
      #           '/Library/Apple/usr/bin'
      #           '/usr/local/go/bin'
      #           '/usr/local/MacGPG2/bin'
      #           '/Applications/Wireshark.app/Contents/MacOS'
      #         ]
      #       # Remove any duplicates we might've added.
      #       | uniq
      #       # Remove any blanks we might've added.
      #       | compact
      #     )
      #   '';
      # };
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

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Extra directories to add to PATH.
    sessionPath = [
      # Add JetBrains scripts to path
      "${home-directory}/Library/Application Support/JetBrains/Toolbox/scripts"
      # Add cargo bin to path
      "${home-directory}/.cargo/bin"
    ];

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/joneshf/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
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
      allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) unfreePackages;
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

      plugins = [
        pkgs.unstable.gh
      ];
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
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUE+CV+yYgdxd391DI/cBlb6QE50pu+i3XYia9IsuUH";
        };
      };

      lfs = {
        enable = true;
      };

      # signing = {
      #   key = "2ACB6C3376555123";

      #   signByDefault = true;
      # };

      userEmail = "jones3.hardy@gmail.com";

      userName = "joneshf";
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
