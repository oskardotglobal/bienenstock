localSelf:

{ inputs, config, ... }:
let
  inherit (localSelf.inputs) nix-pkgset;
  cfg = config.flake.bienenstock;
in
with inputs.nixpkgs.lib;
{
  options.flake.bienenstockLib = mkOption {
    type = types.attrsOf types.anything;
    default = { };
    description = ''
      Define custom library functions (and packages) to pass to all hosts.  
      May be instantiated by calling using an attrset containing a nixpkgs instance `pkgs`.

      When instantiated, all functions in the `packages` attr will be wrapped in `pkgs.callPackage`.
      All packages in the `packages.exports` attrset will be exposed as flake outputs.
      This behaviour can be controlled using `bienenstock.enablePackages`.

      The packages will also be available as `bienenstockPkgs` as a module argument.
    '';
  };

  config = {
    flake.bienenstockLib = rec {
      mapIf =
        cond: apply: value:
        if (cond value) then (apply value) else value;
      mapIf' = cond: apply: mapIf (_: cond) (_: apply);

      packages.exports = { };
      __functor =
        let
          toPackages =
            self':
            mapAttrsRecursive (name: mapIf (_: builtins.head name == "packages") (f: self'.callPackage f { }));
        in
        self:
        { pkgs }:
        mapIf' cfg.enablePackages (nix-pkgset.lib.makePackageSet pkgs (toPackages self)) self;
    };

    perSystem = mkIf cfg.enablePackages (
      { pkgs, ... }:
      {
        packages = (config.flake.bienenstockLib { inherit pkgs; }).packages.exports;
      }
    );
  };
}
