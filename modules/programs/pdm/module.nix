{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.pdm.enable {
    home = {
      packages = [ config.programs.pdm.package ];
    };

    programs = {
      bash = lib.modules.mkIf config.programs.pdm.enableBashIntegration {
        initExtra = lib.modules.mkIf config.programs.pdm.pep-582.enable ''
          eval "$(${config.programs.pdm.package}/bin/pdm --pep582 bash)"
        '';
      };

      fish = lib.modules.mkIf config.programs.pdm.enableFishIntegration {
        shellInit = lib.modules.mkIf config.programs.pdm.pep-582.enable ''
          ${config.programs.pdm.package}/bin/pdm --pep582 fish | source
        '';
      };

      nushell = lib.modules.mkIf config.programs.pdm.enableNushellIntegration {
        extraEnv = lib.modules.mkIf config.programs.pdm.pep-582.enable ''
          # Unfortunately, `pdm` doesn't support `nushell`.
          # We use the output of the `fish` support to munge something out of it.
          $env.PYTHONPATH = (
            # Evaluate `pdm --pep582` in fish,
            # and return a environment-separated string.
            | ${pkgs.fish}/bin/fish --command='eval (${config.programs.pdm.package}/bin/pdm --pep582); echo "$PYTHONPATH"'
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

      zsh = lib.modules.mkIf config.programs.pdm.enableZshIntegration {
        initExtra = lib.modules.mkIf config.programs.pdm.pep-582.enable ''
          eval "$(${config.programs.pdm.package}/bin/pdm --pep582 zsh)"
        '';
      };
    };
  };

  options = {
    programs = {
      pdm = {
        enable = lib.options.mkEnableOption "PDM: a modern Python package and dependency manager supporting the latest PEP standards.";

        enableBashIntegration = lib.options.mkEnableOption "Bash integration" // {
          default = true;
        };

        enableFishIntegration = lib.options.mkEnableOption "Fish integration" // {
          default = true;
        };

        enableNushellIntegration = lib.options.mkEnableOption "Nushell integration" // {
          default = true;
        };

        enableZshIntegration = lib.options.mkEnableOption "Zsh integration" // {
          default = true;
        };

        package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "pdm" { };

        pep-582 = {
          enable = lib.options.mkEnableOption "PEP 582" // {
            default = true;
          };
        };
      };
    };
  };
}
