{ inputs, config, ... }:
let
  inherit (inputs) nix-pkgset;
  inherit (inputs.nixpkgs) lib;

  cfg = config.bienenstock;
in
with lib;
{
  config.flake.bienenstockLib = rec {
    mapIf =
      cond: apply: value:
      if (cond value) then (apply value) else value;
    mapIf' = cond: apply: mapIf (_: cond) (_: apply);

    __functor =
      let
        toPackages =
          self':
          mapAttrsRecursive (
            name: mapIf (_: (builtins.head name) == "packages") (f: self'.callPackage f { })
          );
      in
      self:
      { pkgs }:
      mapIf' cfg.enablePackages (nix-pkgset.lib.makePackageSet pkgs (toPackages self)) self;
  };

}
