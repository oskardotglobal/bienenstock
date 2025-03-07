flake:

{ sources, config, ... }:
let
  inherit (flake.inputs) nix-pkgset;
  cfg = config.bienenstock;
in
with sources.nixpkgs.lib;
{
  options.bienenstockLib = mkOption {
    type = types.attrsOf types.anything;
    default = { };
    description = ''
      Define custom library functions (and packages) to pass to all hosts.  
      May be instantiated by calling using an attrset containing a nixpkgs instance `pkgs`.

      When instantiated, all functions in the `packages` attr will be wrapped in `pkgs.callPackage`.
      This behaviour can be controlled using `bienenstock.enablePackages`.

      The packages will also be available as `bienenstockPkgs` as a module argument.
    '';
  };

  config.bienenstockLib = rec {
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
