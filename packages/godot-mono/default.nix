{
  callPackage,
  godot_4-mono,
  ...
}:

callPackage ../../lib/for-host-platform.nix { } {
  aarch64-darwin = callPackage ./darwin.nix { };
  aarch64-linux = godot_4-mono;
  x86_64-darwin = callPackage ./darwin.nix { };
  x86_64-linux = godot_4-mono;
}
