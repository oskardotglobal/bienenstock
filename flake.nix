{
  description = "NixOS deployment tool & project manager based on colmena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-pkgset = {
      url = "github:szlend/nix-pkgset";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      let
        flakeModules.default = import ./flakeModules self;
      in
      {
        flake = {
          inherit flakeModules;

          templates.default = {
            path = ./template;
            description = "Basic bienenstock project";
          };
        };
      }
    );
}
