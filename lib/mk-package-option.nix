# Helper that make using `lib.options.mkPackageOption` work easier for default values.
# `lib.options.mkPackageOption` takes a default value,
# but it has to be a `string | [string]` that gets used as the attribute path on the `pkgs`.
# This works great when the package is in `pkgs`.
# It falls apart when the package is not in `pkgs`.
# This helper exists to make that easier to deal with.
{ lib, ... }:

pkgs:

name:

{
  default ? name,
  ...
}@options:

if builtins.isString default then
  lib.options.mkPackageOption pkgs name options
else if builtins.isList default then
  lib.options.mkPackageOption pkgs name options
else
  lib.options.mkPackageOption pkgs name (
    options
    // {
      default = null;
    }
  )
  // {
    inherit default;
  }
