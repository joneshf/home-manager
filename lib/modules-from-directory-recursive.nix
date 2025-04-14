{
  directory,
  lib,
  ...
}:

let
  is-module-file = filePath: builtins.baseNameOf filePath == "module.nix";

  # Convert an absolute file path to an attrset nested by its directory structure.
  # The keys are the directories that are are relative to `directory`,
  # and the value is the absolute file path.
  #
  # E.g. given:
  # - `directory`: `./some/path/to/modules`
  # - `absolute-file-path`: `./some/path/to/modules/a/great/one/module.nix`
  #
  # The result should be:
  # ```Nix
  # {
  #   a = {
  #     great = {
  #       one = ./some/path/to/modules/a/great/one/module.nix;
  #     };
  #   };
  # }
  # ```
  mk-module-attrset =
    absolute-file-path:
    lib.trivial.pipe absolute-file-path [
      # Remove everything in the file path up to–and including–the `directory`,
      # so we know where to start looking for modules.
      (lib.path.removePrefix directory)

      # Remove the `module.nix` part of the file path.
      builtins.dirOf

      # Turn any remaining parts of the file path into a list of split on `/`.
      lib.path.subpath.components

      # Create the attrset from the remaining parts of the file path,
      # with its value as the actual absolute file path.
      (module-attr-path: lib.attrsets.setAttrByPath module-attr-path absolute-file-path)
    ];
in
lib.trivial.pipe directory [
  # Get a list of all file paths (recursively) in the `directory`.
  lib.filesystem.listFilesRecursive

  # Keep only the file paths that are `module.nix` files.
  (builtins.filter is-module-file)

  # Turn those into into attrsets nested by their directory structure.
  (builtins.map mk-module-attrset)

  # Deep merge all the attrsets into a single attrset.
  (builtins.foldl' lib.attrsets.recursiveUpdate { })
]
