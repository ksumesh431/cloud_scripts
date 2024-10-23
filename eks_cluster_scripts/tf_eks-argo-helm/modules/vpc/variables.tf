variable "name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "tags" {
  description = "A map of tags"
  type        = map(string)
  default = {
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

variable "oidc_provider_arn" {
  description = "eks oidc provider arn"
}

variable "eks_managed_node_groups" {
  description = "eks_managed_node_groups"
}

