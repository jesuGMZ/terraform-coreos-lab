output "ip_manager" {
  value = "${digitalocean_droplet.manager.ipv4_address}"
}

output "ip_nodes" {
  value = "${element(digitalocean_droplet.node.*.ipv4_address, 0)}"
}
