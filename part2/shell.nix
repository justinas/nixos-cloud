let
  pkgs = import
    (builtins.fetchGit {
      name = "nixos-unstable-2020-12-29";
      url = "https://github.com/nixos/nixpkgs";
      ref = "refs/heads/nixos-unstable";
      rev = "2f47650c2f28d87f86ab807b8a339c684d91ec56";
    })
    { };
  myTerraform = pkgs.terraform_0_14.withPlugins (tp: [ tp.digitalocean ]);
  ter = pkgs.writeShellScriptBin "ter" ''
    terraform $@ && terraform show -json > show.json
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [ curl jq morph myTerraform ter ];
}
