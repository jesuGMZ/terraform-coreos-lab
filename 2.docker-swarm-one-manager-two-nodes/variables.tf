variable "token" {}

variable "region" {
  default = "ams3"
}

variable "distribution" {
  default = "coreos-stable"
}

variable "ssh_keys" {
  default = ["5f:b8:0d:ee:77:af:91:b0:53:28:62:f3:e2:93:7a:f2"]
}

variable "docker_nodes" {
  default = 2
}
