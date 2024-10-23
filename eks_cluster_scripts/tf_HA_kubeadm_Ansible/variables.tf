variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"

}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "keypair_name" {
  type    = string
  default = "kubeadm-servers-keypair"
}
