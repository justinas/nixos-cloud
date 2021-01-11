# A cookbook for deploying NixOS to cloud servers

* [Part 1](/part1) provides a way to deploy NixOS
  to [DigitalOcean](https://www.digitalocean.com/)
  by building a custom NixOS disk image.
  It also introduces remote management of your cloud servers
  using [Morph](https://github.com/DBCDK/morph)
  and uses this to deploy an instance of nginx HTTP server.
  See also
  [the accompanying article](https://justinas.org/nixos-in-the-cloud-step-by-step-part-1).
* [Part 2](/part2) shows how to spawn NixOS machines in bulk
  using Terraform, as well as how to use Terraform state
  in Nix expressions, in order to automatically deploy
  to the managed infrastructure.
  See also
  [the accompanying article](https://justinas.org/nixos-in-the-cloud-step-by-step-part-2).
