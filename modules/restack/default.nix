{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.restack.enable {
    home = {
      packages =
        [ (pkgs.callPackage ../../packages/restack { }) ]
        ++ lib.lists.optional config.restack.git-restack.enable (
          pkgs.callPackage ../../packages/git-restack { }
        )
        ++ [ ];
    };
  };

  options = {
    restack = {
      enable = lib.mkEnableOption "restack";

      git-restack = {
        enable = lib.mkEnableOption "git-restack" // {
          default = true;
        };
      };
    };
  };
}
