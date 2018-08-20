provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_droplet" "droplet-1" {
  image     = "${var.distribution}"
  name      = "droplet-1"
  region    = "${var.region}"
  size      = "1gb"
  ssh_keys  = "${var.ssh_keys}"
  user_data = "${data.ct_config.config.rendered}"
}

resource "digitalocean_firewall" "firewall-1" {
  name = "firewall-1"

  droplet_ids = ["${digitalocean_droplet.droplet-1.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "443"
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

data "ct_config" "config" {
  content = "${file("coreos-config.yml")}"
  platform = "digitalocean"
}

output "ip" {
  value = "${digitalocean_droplet.droplet-1.ipv4_address}"
}
