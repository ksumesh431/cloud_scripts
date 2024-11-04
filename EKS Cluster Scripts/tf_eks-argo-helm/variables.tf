variable "aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::895884664845:user/eks_user_sumesh"
      username = "eks_user_sumesh"
      groups   = ["system:masters"]
    }
  ]
}

variable "vpc_cidr" {
  description = "cidr of vpc"
  type        = string
  default     = "10.0.0.0/16"
}

