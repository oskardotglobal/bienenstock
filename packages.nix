{ nix-pkgset, ... }:

{ self, ... }:
{
  config.flake.bienenstockLib.packages = {
    bienenstockLib = _: (builtins.removeAttrs self.bienenstockLib [ "packages" ]);

    __functor =
      self: pkgs:
      let
        self' = builtins.removeAttrs self [ "__functor" ];
      in
      nix-pkgset.lib.makePackageSet "bienenstockPkgs" pkgs.newScope (
        scope: builtins.mapAttrs (_: f: scope.callPackage f { }) self'
      );
  };
}
