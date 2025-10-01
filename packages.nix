{ self, ... }:
{
  config.flake.bienenstockLib.packages = {
    bienenstockLib = _: (builtins.removeAttrs self.bienenstockLib [ "packages" ]);

    __functor =
      self: pkgs:
      let
        inherit (pkgs.lib.attrsets) recurseIntoAttrs;
        inherit (pkgs.lib.customisation) makeScope;

        self' = builtins.removeAttrs self [ "__functor" ];
      in
      (scope: builtins.mapAttrs (_: f: scope.callPackage f { }) self')
      |> makeScope pkgs.newScope
      |> recurseIntoAttrs;
  };
}
