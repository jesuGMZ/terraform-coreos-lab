provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "manager" {
  image     = "${var.distribution}"
  name      = "manager"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = ["${var.do_ssh_fingerprint}"]
  user_data = "${data.ct_config.docker-swarm-manager.rendered}"

  provisioner "remote-exec" {
    connection {
      user = "core"
    }

    inline = [
      "sudo docker swarm init --advertise-addr ${self.ipv4_address}",
    ]
  }
}

resource "digitalocean_droplet" "node_general" {
  image     = "${var.distribution}"
  name      = "node-general-${count.index + 1}"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = ["${var.do_ssh_fingerprint}"]
  user_data = "${data.ct_config.common.rendered}"

  count = "${var.amount_node_general}"

  provisioner "remote-exec" {
    connection {
      user = "core"
    }

    inline = [
      "sudo docker swarm join --token $(sudo docker --host ${digitalocean_droplet.manager.ipv4_address} swarm join-token worker --quiet) ${digitalocean_droplet.manager.ipv4_address}:2377",
    ]
  }
}

resource "digitalocean_droplet" "node_database" {
  image     = "${var.distribution}"
  name      = "node-database-${count.index + 1}"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = ["${var.do_ssh_fingerprint}"]
  user_data = "${data.ct_config.common.rendered}"

  count = 1

  provisioner "remote-exec" {
    connection {
      user = "core"
    }

    inline = [
      "sudo docker swarm join --token $(sudo docker --host ${digitalocean_droplet.manager.ipv4_address} swarm join-token worker --quiet) ${digitalocean_droplet.manager.ipv4_address}:2377",
    ]
  }
}

resource "null_resource" "add_label_general" {
  count = "${var.amount_node_general}"

  connection {
    user = "core"
    host = "${digitalocean_droplet.manager.ipv4_address}"
    private_key = "${file("${var.ssh_private_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker node update --label-add type=general ${element(digitalocean_droplet.node_general.*.name, count.index)}",
    ]
  }
}

resource "null_resource" "add_label_database" {
  count = 1

  connection {
    user = "core"
    host = "${digitalocean_droplet.manager.ipv4_address}"
    private_key = "${file("${var.ssh_private_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker node update --label-add type=database ${element(digitalocean_droplet.node_database.*.name, count.index)}",
    ]
  }
}

resource "digitalocean_firewall" "firewall" {
  name = "firewall"

  droplet_ids = [
    "${digitalocean_droplet.manager.id}",
    "${digitalocean_droplet.node_general.*.id}",
    "${digitalocean_droplet.node_database.*.id}",
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
