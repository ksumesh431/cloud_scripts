variable "vpc_cidr_block" {
  description = "vpc cidr"
  type        = string
}



# CIDR variables for subnetss

variable "pub_1_cidr" {
  description = "cidr block for public subnet 1"
  type        = string
}
variable "pub_2_cidr" {
  description = "cidr block for public subnet 2"
  type        = string
}
variable "priv_1_cidr" {
  description = "cidr block for private subnet 1"
  type        = string
}
variable "priv_2_cidr" {
  description = "cidr block for private subnet 2"
  type        = string
}



# Availibility zone variables for subnets

variable "pub_1_az" {
  description = "AZ for public subnet 1"
  type        = string
  default     = "ap-south-1a"
}
variable "pub_2_az" {
  description = "AZ for public subnet 2"
  default     = "ap-south-1b"
  type        = string
}
variable "priv_1_az" {
  description = "AZ for private subnet 1"
  default     = "ap-south-1a"
  type        = string
}
variable "priv_2_az" {
  description = "AZ for private subnet 2"
  default     = "ap-south-1b"
  type        = string
}
