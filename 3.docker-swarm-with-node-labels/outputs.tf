output "manager_ip" {
  value = "${digitalocean_droplet.manager.ipv4_address}"
}

output "node_general_ips" {
  value = "${concat(digitalocean_droplet.node_general.*.ipv4_address)}"
}

output "node_database_ips" {
  value = "${concat(digitalocean_droplet.node_database.*.ipv4_address)}"
}
