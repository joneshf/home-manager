{
  callPackage,
  godot_4,
  ...
}:

callPackage ../../lib/for-host-platform.nix { } {
  aarch64-darwin = callPackage ./darwin.nix { };
  aarch64-linux = godot_4;
  x86_64-darwin = callPackage ./darwin.nix { };
  x86_64-linux = godot_4;
}
