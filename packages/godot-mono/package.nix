{
  callPackage,
  dotnetCorePackages,
  godot_4-mono,
  # The recommendation in `nixpkgs` is to use `dotnetCorePackages.sdk_<major>_<minor>`:
  # https://github.com/NixOS/nixpkgs/blob/ca82b3ec2b85899573cf03075021bc2eb0b585a8/doc/languages-frameworks/dotnet.section.md#dotnet-sdk-vs-dotnetcorepackagessdk-dotnet-sdk-vs-dotnetcorepackagessdk.
  #
  # This recommendation is fine when the .NET SDK has to be a specific version known at build time,
  # even if it's only used at runtime.
  # For a package like this,
  # where the .NET SDK is entirely a runtime dependency that can change in different usages of this same package,
  # the use of `donetCorePackages.sdk_<major>_<minor>` makes it harder to override this dependency.
  # Someone consuming this package would have to know what attribute it uses in order to know how to override the dependency properly.
  # The override might also not make much sense from a semantic perspective.
  # E.g. they might want to have the .NET SDK at 9.0,
  # so they'd have to say something like:
  # ```Nix
  # pkgs.godot-mono.override {
  #   dotnetCorePackages = pkgs.dotnetCorePackages // {
  #     sdk_8_0 = pkgs.dotnetCorePackages.sdk_9_0;
  #   };
  # }
  # ```
  # Which is confusing at best.
  #
  # We could take `dotnet-sdk` as an argument,
  # but that makes it look like we actually want the `dotnet-sdk` package in `nixpkgs`.
  #
  # To make it a bit more explicit what we actually want,
  # we name this attribute `override-dotnet-sdk`.
  # This way,
  # when someone wants a different .NET SDK,
  # it's not super confusing because the versions aren't in the attribute.
  # E.g.:
  # ```Nix
  # pkgs.godot-mono.override {
  #   override-dotnet-sdk = args.dotnetCorePackages.sdk_9_0;
  # }
  # ```
  override-dotnet-sdk ? dotnetCorePackages.sdk_8_0,
  ...
}:

callPackage ../../lib/for-host-platform.nix { } {
  aarch64-darwin = callPackage ./darwin.nix {
    inherit override-dotnet-sdk;
  };

  aarch64-linux = godot_4-mono.override {
    dotnetCorePackages = dotnetCorePackages // {
      sdk_8_0-source = override-dotnet-sdk;
    };
  };

  x86_64-darwin = callPackage ./darwin.nix {
    inherit override-dotnet-sdk;
  };

  x86_64-linux = godot_4-mono.override {
    dotnetCorePackages = dotnetCorePackages // {
      sdk_8_0-source = override-dotnet-sdk;
    };
  };
}
