{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.modules.mkIf config.finance.enable (
    lib.modules.mkMerge [
      (lib.modules.mkIf config.finance.beancount.enable (
        lib.modules.mkMerge [
          {
            home = {
              packages = [
                config.finance.beancount.package
              ];
            };
          }

          (lib.modules.mkIf config.finance.beancount.fava.enable {
            home = {
              packages = [
                config.finance.beancount.fava.package
              ];
            };
          })
        ]
      ))

      (lib.modules.mkIf config.finance.buckets.enable {
        home = {
          packages = [
            config.finance.buckets.package
          ];
        };
      })

      (lib.modules.mkIf config.finance.turbotax-2024.enable {
        home = {
          packages = [
            config.finance.turbotax-2024.package
          ];
        };
      })
    ]
  );

  options = {
    finance = {
      enable = lib.options.mkEnableOption "finance";

      beancount = {
        enable = lib.options.mkEnableOption "Beancount" // {
          default = config.finance.enable;
        };

        fava = {
          enable = lib.options.mkEnableOption "Fava" // {
            default = config.finance.beancount.enable;
          };

          package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "fava" { };
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "beancount" { };
      };

      buckets = {
        enable = lib.options.mkEnableOption "Buckets" // {
          default = config.finance.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "buckets" { };
      };

      turbotax-2024 = {
        enable = lib.options.mkEnableOption "TurboTax 2024" // {
          default = config.finance.enable;
        };

        package = pkgs.callPackage ../../lib/mk-package-option.nix { } pkgs "turbotax-2024" { };
      };
    };
  };
}
