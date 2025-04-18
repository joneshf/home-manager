{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.programs.godot.enable {
    home = {
      packages =
        [ config.programs.godot.package ]
        ++ lib.lists.optional config.programs.godot.mono.enable (
          config.programs.godot.mono.package.override {
            override-dotnet-sdk = config.programs.godot.mono.override-dotnet-sdk;
          }
        )
        ++ [ ];
    };
  };

  options = {
    programs = {
      godot = {
        enable = lib.options.mkEnableOption "godot";

        mono = {
          enable = lib.options.mkEnableOption "mono" // {
            default = true;
          };

          override-dotnet-sdk =
            pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs [ "dotnetCorePackages" "sdk_8_0" ]
              {
                nullable = true;
              };

          package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "Godot_mono" {
            default = pkgs.callPackage ../../../packages/godot-mono/package.nix { };
          };
        };

        package = pkgs.callPackage ../../../lib/mk-package-option.nix { } pkgs "Godot" {
          default = pkgs.callPackage ../../../packages/godot/package.nix { };
        };
      };
    };
  };
}
