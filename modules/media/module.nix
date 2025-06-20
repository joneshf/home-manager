{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.media.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.media.spotify.enable {
        home = {
          packages = [
            config.media.spotify.package
          ];
        };

        nixpkgs = {
          unfree-packages = {
            allow = [
              (lib.strings.getName config.media.spotify.package)
            ];

            enable = true;
          };
        };
      })
    ]
  );

  imports = [
    ../nixpkgs/unfree-packages/module.nix
  ];

  options = {
    media = {
      enable = lib.options.mkEnableOption "media";

      spotify = {
        enable = lib.options.mkEnableOption "Spotify" // {
          default = config.media.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "spotify" { };
      };
    };
  };
}
