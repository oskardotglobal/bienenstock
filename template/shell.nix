{
  sources ? import ./sources,
  system ? builtins.currentSystem,
  pkgs ? sources.nixpkgs.legacyPackages."${system}",
  ...
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    colmena
    just
  ];

  shellHook = ''
    tmp="$(mktemp -p /tmp)"

    nix-instantiate --eval -E "(import ./default.nix { }).bienenstock.sshConfig" \
      | sed -E \
          -e 's/^"(.*)"$/\1/' \
          -e 's/\\n/\n/g' \
      > "$tmp"

    alias ssh="ssh -F $tmp"
  '';
}
