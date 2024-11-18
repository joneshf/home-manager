# Helper for providing a bunch of system-specific values.
# No system is required to be passed in,
# but using an attrset for the systems lets us not have to deal with misspelling a system.
{ lib, stdenv, ... }:

systems@{
  # deadnix: skip
  aarch64-darwin ? null,
  # deadnix: skip
  aarch64-linux ? null,
  # deadnix: skip
  aarch64-windows ? null,
  # deadnix: skip
  x86_64-darwin ? null,
  # deadnix: skip
  x86_64-linux ? null,
  # deadnix: skip
  x86_64-windows ? null,
}:

lib.attrsets.attrByPath [
  stdenv.hostPlatform.system
] (throw "Unsupported system: ${stdenv.hostPlatform.system}") systems
