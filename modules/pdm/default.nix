{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.pdm.enable {
    home = {
      packages = [ config.pdm.package ];
    };

    programs = {
      bash = lib.mkIf config.pdm.enableBashIntegration {
        initExtra = lib.mkIf config.pdm.pep-582.enable ''
          eval "$(${config.pdm.package}/bin/pdm --pep582 bash)"
        '';
      };

      fish = lib.mkIf config.pdm.enableFishIntegration {
        shellInit = lib.mkIf config.pdm.pep-582.enable ''
          ${config.pdm.package}/bin/pdm --pep582 fish | source
        '';
      };

      zsh = lib.mkIf config.pdm.enableZshIntegration {
        initExtra = lib.mkIf config.pdm.pep-582.enable ''
          eval "$(${config.pdm.package}/bin/pdm --pep582 zsh)"
        '';
      };
    };
  };

  options = {
    pdm = {
      enable = lib.mkEnableOption "PDM: a modern Python package and dependency manager supporting the latest PEP standards.";

      enableBashIntegration = lib.mkEnableOption "Bash integration" // {
        default = true;
      };

      enableFishIntegration = lib.mkEnableOption "Fish integration" // {
        default = true;
      };

      enableZshIntegration = lib.mkEnableOption "Zsh integration" // {
        default = true;
      };

      package = lib.mkPackageOption pkgs "pdm" { };

      pep-582 = {
        enable = lib.mkEnableOption "PEP 582" // {
          default = true;
        };
      };
    };
  };
}
