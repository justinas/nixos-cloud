{ pkgs ? import <nixpkgs> { } }:
let
  myTerraform = pkgs.terraform.withPlugins (tp: [ tp.digitalocean ]);
  ter = pkgs.writeShellScriptBin "ter" ''
    terraform $@ && terraform show -json > show.json
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [ curl jq morph myTerraform ter ];
}
