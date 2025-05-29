{
  description = "A flake library for deploy-rs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-pkgset = {
      url = "github:szlend/nix-pkgset";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      deploy-rs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./lib.nix
        ./module.nix
      ];

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

          devShells.default = pkgs.mkShellNoCC {
            shellHook = ''
              tmp="$(mktemp -p /tmp)"

              nix eval --impure --json .#bienenstock.sshConfig \
                | sed -E \
                    -e 's/^"(.*)"$/\1/' \
                    -e 's/\\n/\n/g' \
                > "$tmp"

              export SSH_CONFIG_FILE="$tmp"
            '';
          };
        };

      flake =
        let
          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        in
        {
          inherit checks;
          inherit (flake-parts.lib) mkFlake;

          flakeModules.default = {
            imports = [
              ./lib.nix
              ./module.nix
            ];

            flake = { inherit checks; };
          };
        };
    };
}
