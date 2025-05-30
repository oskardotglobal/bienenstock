inputs':

{ self, inputs, ... }:
let
  inherit (inputs') nix-pkgset;
  inherit (inputs.nixpkgs) lib;

  flake = self;
in
with lib;
{
  config.flake.bienenstockLib = rec {
    mapIf =
      cond: apply: value:
      if (cond value) then (apply value) else value;
    mapIf' = cond: apply: mapIf (_: cond) apply;

    __functor =
      self: pkgs:
      let
        toPackages =
          self':
          mapAttrsRecursive (name: f: self'.callPackage f { inherit (flake) bienenstockLib; }) self.packages;
      in
      nix-pkgset.lib.makePackageSet "bienenstockPkgs" pkgs.newScope toPackages;
  };

}
