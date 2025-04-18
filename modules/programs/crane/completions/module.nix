{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.crane.completions.enable {
    home = {
      packages = [ (pkgs.callPackage ../../../../packages/crane-completions/package.nix { }) ];
    };
  };

  options = {
    programs = {
      crane = {
        completions = {
          enable = lib.options.mkEnableOption "crane completions";
        };
      };
    };
  };
}
