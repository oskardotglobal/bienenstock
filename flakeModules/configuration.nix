{
  name,
  nixpkgs,
  rootAuthorizedKeys,
  ...
}:
{
  deployment.replaceUnknownProfiles = false;

  users.users.root.openssh.authorizedKeys.keys = rootAuthorizedKeys;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
  };

  networking.hostName = name;

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    registry.nixpkgs.flake = nixpkgs;
    channel.enable = false;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };
}
