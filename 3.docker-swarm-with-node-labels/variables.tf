variable "do_token" {}

variable "region" {
  default = "ams3"
}

variable "distribution" {
  default = "coreos-stable"
}

variable "do_ssh_fingerprint" {}

variable "ssh_private_key_path" {}

variable "amount_node_general" {
  default = 2
}
