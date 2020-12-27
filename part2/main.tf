provider "digitalocean" {}

resource "digitalocean_droplet" "backend" {
  name     = "backend${count.index + 1}"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  image    = 75674995
  ssh_keys = [27010799]

  count = 2
}

resource "digitalocean_droplet" "loadbalancer" {
  name     = "loadbalancer${count.index + 1}"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  image    = 75674995
  ssh_keys = [27010799]

  count = 2
}
