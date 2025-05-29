{
  self,
  inputs,
  ...
}:
let
  inherit (inputs) nixpkgs deploy-rs sops-nix;
  inherit (self) mkCmweddingPkgs;
in
{
  flake.cmweddingLib = rec {
    mkNode =
      {
        hostname,
        system,
        remoteBuild ? false,
      }:
      rec {
        nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = rec {
            inherit (self) cmweddingLib;
            inherit system;

            pkgs = nixpkgs.legacyPackages."${system}";
            cmweddingPkgs = mkCmweddingPkgs pkgs;
          };

          modules = [
            sops-nix.nixosModules.sops
            (import "${self}/hosts/${hostname}/configuration.nix")
            (
              { pkgs, ... }:
              {
                nixpkgs.config.allowUnfree = true;
                nix = {
                  settings.experimental-features = [
                    "nix-command"
                    "flakes"
                    "pipe-operators"
                  ];

                  registry.nixpkgs.flake = nixpkgs;
                  channel.enable = false;
                  nixPath = [
                    "nixpkgs=${nixpkgs}"
                  ];
                };

                programs.nh = {
                  enable = true;
                  clean.enable = pkgs.lib.mkDefault true;
                };
              }
            )
          ];
        };

        deploy.nodes."${hostname}" = {
          inherit hostname remoteBuild;
          sshUser = "root";

          profiles.system = {
            user = "root";

            path = deploy-rs.lib."${system}".activate.nixos nixosConfigurations."${hostname}";
          };
        };
      };

    mkNodes =
      nodes:
      nodes
      |> inputs.nixpkgs.lib.attrsToList
      |> builtins.map (e: mkNode (e.value // { hostname = e.name; }))
      |> self.cmweddingLib.recursiveMerge;
  };
}
