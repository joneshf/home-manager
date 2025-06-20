{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.nixpkgs.unfree-packages.enable {
    nixpkgs = {
      config = {
        allowUnfreePredicate =
          pkg: builtins.elem (pkgs.lib.getName pkg) config.nixpkgs.unfree-packages.allow;
      };
    };
  };

  options = {
    nixpkgs = {
      unfree-packages = {
        allow = lib.options.mkOption {
          default = [ ];
          description = "The list of unfree packages that are allowed.";
          type = lib.types.listOf lib.types.str;
        };

        enable = lib.options.mkEnableOption "unfree-packages";
      };
    };
  };
}
