variable "name" {
  description = "Name for the resource"
  type        = string
#   default     = "skp-${replace(basename(path.cwd), "_", "-")}"
}

variable "cluster_version" {
  description = "Version of the cluster"
  type        = string
  default     = "1.27"
}

variable "tags" {
  description = "A map of tags"
  type        = map(string)
  default = {
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

variable "aws_auth_roles" {
  description = "List of AWS IAM roles for Kubernetes authentication"
  type        = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "instance_types" {
  description = "List of EC2 instance types"
  type        = list(string)
  default     = ["t3.small"]
}


variable "vpc_id" {
  description = "VPC id"
}
variable "private_subnets" {
  description = "VPC private subnets"
}
variable "intra_subnets" {
  description = "VPC intra subnets for control plane"
}
