# Remote state S3 bucket variables
variable "product" {
  description = "The name of the product"
  type        = string
  default     = "erp"
}

variable "environment" {
  description = "environment type"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "895884664845"
}


variable "tags" {
  type        = map(string)
  description = "AWS tags that will be applied to all resources"
  default     = {
    "VERSION" = "1"
  }
}

variable "eks_role_arns" {
  type        = list(string)
  default     = ["arn:aws:iam::895884664845:user/eks_user_sumesh"]
  description = "Additional IAM roles that should be added to the AWS auth config map"
}

