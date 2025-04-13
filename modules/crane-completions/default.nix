{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.crane-completions.enable {
    home = {
      packages = [ (pkgs.callPackage ../../packages/crane-completions/package.nix { }) ];
    };
  };

  options = {
    crane-completions = {
      enable = lib.mkEnableOption "crane-completions";
    };
  };
}
