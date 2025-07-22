{ self, ... }:
{
  config.flake.bienenstockLib.packages = {
    bienenstockLib = _: (builtins.removeAttrs self.bienenstockLib [ "packages" ]);

    __functor =
      self: pkgs:
      let
        inherit (pkgs) lib;
        self' = builtins.removeAttrs self [ "__functor" ];
      in
      lib.makeScope pkgs.newScope (scope: builtins.mapAttrs (_: f: scope.callPackage f { }) self');
  };
}
