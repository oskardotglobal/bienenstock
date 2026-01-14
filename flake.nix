{
  description = "A flake library for deploy-rs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-pkgset = {
      url = "github:szlend/nix-pkgset/60e06913b0d15b4c35534a070de109cd413038c8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      deploy-rs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          ...
        }:
        {
          formatter = pkgs.nixfmt-tree;

          packages.docs = pkgs.callPackage (
            {
              lib,
              nixosOptionsDoc,
              ...
            }:
            let
              eval = lib.evalModules {
                modules = [
                  ./options.nix
                ];

                specialArgs = {
                  inherit inputs;
                };
              };

              optionsDoc = nixosOptionsDoc {
                inherit (eval) options;
              };
            in
            optionsDoc.optionsCommonMark
          ) { };
        };

      flake =
        let
          inherit (flake-parts.lib) mkFlake importApply;
        in
        {
          inherit mkFlake;

          flakeModules.default =
            { self, ... }:
            {
              imports = [
                ./options.nix
                ./packages.nix
                (importApply ./module.nix inputs)
              ];

              perSystem =
                { system, ... }:
                {
                  checks = deploy-rs.lib."${system}".deployChecks self.deploy;
                };
            };
        };
    };
}
