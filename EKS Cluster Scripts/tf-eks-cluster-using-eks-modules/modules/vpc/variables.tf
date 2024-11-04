variable "product" {
  type        = string
  description = "Product Name"
}


variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}