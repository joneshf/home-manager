{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.restack.enable {
    home = {
      packages =
        [ (pkgs.callPackage ../../../packages/restack/package.nix { }) ]
        ++ lib.lists.optional config.programs.restack.git-restack.enable (
          pkgs.callPackage ../../../packages/git-restack/package.nix { }
        )
        ++ [ ];
    };
  };

  options = {
    programs = {
      restack = {
        enable = lib.options.mkEnableOption "restack";

        git-restack = {
          enable = lib.options.mkEnableOption "git-restack" // {
            default = true;
          };
        };
      };
    };
  };
}
