{
  config,
  lib,
  ...
}:

{
  config = {
    programs = {
      fish = {
        plugins = builtins.map (package: {
          name = package.pname;
          src = package.src;
        }) config.programs.fish.package-plugins;
      };
    };
  };

  options = {
    programs = {
      fish = {
        package-plugins = lib.options.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "The set of Fish plugin packages to add to `programs.fish.plugins`.";
        };
      };
    };
  };
}
