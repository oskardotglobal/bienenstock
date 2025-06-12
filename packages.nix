{ self, ... }:
{
  config.flake.bienenstockLib.packages = {
    bienenstockLib = _: (builtins.removeAttrs self.bienenstockLib [ "packages" ]);

    __functor =
      packages: pkgs:
      let
        callPackage = pkgs.lib.callPackageWith (pkgs // packages);
      in
      builtins.mapAttrs (_: f: callPackage f { inherit callPackage; }) packages;
  };
}
