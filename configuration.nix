{
  cfg,
  name,
  nixpkgs,
}:

{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];
  nixpkgs = { inherit pkgs; };

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

  users.users.root.openssh.authorizedKeys.keys = cfg.rootAuthorizedKeys;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = pkgs.lib.mkDefault true;
  };

  networking.hostName = name;
}
