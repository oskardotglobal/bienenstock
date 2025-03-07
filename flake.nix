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
  };

  outputs =
    { self, ... }:
    {
      module = import ./module self;

      mkEntrypoint =
        sources: main:
        (sources.nixpkgs.lib.evalModules {
          modules = [ main ];
          specialArgs = { inherit sources; };
        }).config;

      templates.default = {
        path = ./template;
        description = "Basic bienenstock project";
      };
    };
}
