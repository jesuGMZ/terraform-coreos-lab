variable "token" {}

variable "region" {
  default = "ams3"
}

variable "distribution" {
  default = "coreos-stable"
}

variable "ssh_keys" {
  default = ["<DIGITALOCEAN_SSHKEY_FINGERPRINT>"]
}

variable "docker_nodes" {
  default = 2
}
