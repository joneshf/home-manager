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

        enableZshIntegration = lib.options.mkEnableOption "Zsh integration" // {
          default = true;
        };

        package = lib.options.mkPackageOption pkgs "pdm" { };

        pep-582 = {
          enable = lib.options.mkEnableOption "PEP 582" // {
            default = true;
          };
        };
      };
    };
  };
}
