{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.godot.enable {
    home = {
      packages =
        [ config.godot.package ]
        ++ lib.lists.optional config.godot.mono.enable config.godot.mono.package
        ++ [ ];
    };

    launchd = lib.mkIf pkgs.stdenv.isDarwin {
      agents = {
        setenv-DOTNET_ROOT = lib.mkIf config.godot.mono.enable {
          config = {
            KeepAlive = true;

            ProgramArguments = [
              "/bin/launchctl"
              "setenv"
              "DOTNET_ROOT"
              "${pkgs.dotnet-sdk}/share/dotnet"
            ];

            RunAtLoad = true;
          };

          enable = true;
        };

        setenv-prepend-PATH = lib.mkIf config.godot.mono.enable {
          config = {
            KeepAlive = true;

            ProgramArguments = [
              "/bin/launchctl"
              "setenv"
              "PATH"
              "${lib.strings.makeBinPath [ pkgs.dotnet-sdk ]}:$(/bin/launchctl getenv PATH)"
            ];

            RunAtLoad = true;
          };

          enable = true;
        };
      };
    };
  };

  options = {
    godot = {
      enable = lib.mkEnableOption "godot";

      mono = {
        enable = lib.mkEnableOption "mono" // {
          default = true;
        };

        package =
          lib.mkPackageOption pkgs "Godot_mono" {
            # We want to use the package defined in `../../packages/godot-mono` as the default.
            # This option has to be a `string | [string]` based on the path within `pkgs`.
            # The package in `../../packages/godot-mono` isn't within `pkgs`.
            # So we set this to `null` explicitly,
            # and set the actual `default` below where we can use full `nix` syntax.
            default = null;
          }
          // {
            default = pkgs.callPackage ../../packages/godot-mono { };
          };
      };

      package =
        lib.mkPackageOption pkgs "Godot" {
          # We want to use the package defined in `../../packages/godot` as the default.
          # This option has to be a `string | [string]` based on the path within `pkgs`.
          # The package in `../../packages/godot` isn't within `pkgs`.
          # So we set this to `null` explicitly,
          # and set the actual `default` below where we can use full `nix` syntax.
          default = null;
        }
        // {
          default = pkgs.callPackage ../../packages/godot { };
        };
    };
  };
}
