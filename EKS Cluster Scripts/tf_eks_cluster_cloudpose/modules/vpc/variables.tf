variable "region" {
  type        = string
  description = "AWS Region"
}

variable "stage" {
  type        = string
  description = "stage"
}

variable "namespace" {
  type        = string
  description = "namespace"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a","us-east-1b","us-east-1c"]
  description = "availability_zones"
}

variable "cidr_block" {
  type        = string
  description = "cidr_block"
}