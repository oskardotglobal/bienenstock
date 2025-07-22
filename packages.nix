{ self, ... }:
{
  config.flake.bienenstockLib.packages = {
    bienenstockLib = _: (builtins.removeAttrs self.bienenstockLib [ "packages" ]);

    __functor =
      packages: pkgs:
      let
        inherit (pkgs) lib;
      in
      lib.fix (
        self:
        let
          callPackage = lib.callPackageWith (pkgs // self);
        in
        builtins.mapAttrs (_: f: callPackage f { }) packages
      );
  };
}
