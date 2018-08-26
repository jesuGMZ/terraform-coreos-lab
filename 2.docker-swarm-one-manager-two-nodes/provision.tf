provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_droplet" "manager" {
  image     = "${var.distribution}"
  name      = "manager"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = "${var.ssh_keys}"
  user_data = "${data.ct_config.docker-swarm-manager.rendered}"

  provisioner "remote-exec" {
    connection {
      user = "core"
    }

    inline = [
      "sudo docker swarm init --advertise-addr ${self.ipv4_address}"
    ]
  }
}

resource "digitalocean_droplet" "node" {
  image     = "${var.distribution}"
  name      = "node-${count.index + 1}"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = "${var.ssh_keys}"
  user_data = "${data.ct_config.common.rendered}"

  count = "${var.docker_nodes}"

  provisioner "remote-exec" {
    connection {
      user = "core"
    }

    inline = [
      "sudo docker swarm join --token $(sudo docker --host ${digitalocean_droplet.manager.ipv4_address} swarm join-token worker --quiet) ${digitalocean_droplet.manager.ipv4_address}:2377"
    ]
  }
}

resource "digitalocean_firewall" "firewall" {
  name = "firewall"

  droplet_ids = [
    "${digitalocean_droplet.manager.id}",
    "${digitalocean_droplet.node.*.id}"
  ]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}

data "ct_config" "common" {
  content = "${file("common.yml")}"
  platform = "digitalocean"
}

data "ct_config" "docker-swarm-manager" {
  content = "${file("docker-swarm-manager.yml")}"
  platform = "digitalocean"

  snippets = [
    "${file("common.yml")}"
  ]
}
