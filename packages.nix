inputs':

{ self, ... }:
let
  inherit (inputs') nix-pkgset;
in
{
  config.flake.bienenstockLib = {
    packages.bienenstockLib = _: self.bienenstockLib;

    __functor =
      { packages, ... }:
      pkgs:
      let
        toPackages = self: builtins.mapAttrs (_: f: self.callPackage f { }) packages;
      in
      nix-pkgset.lib.makePackageSet "bienenstockPkgs" pkgs.newScope toPackages;
  };
}
