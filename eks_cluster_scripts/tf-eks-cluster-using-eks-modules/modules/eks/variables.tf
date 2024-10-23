variable "product" {
  type        = string
  description = "Product Name"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "private_subnet_id" {
  description = "VPC Id"
  type        = list
}

# Cluster Related configuration
variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type = string
  default     = null
}
variable "enable_cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "enable_cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

# Incase we want to restrict the access to api server to specific subnet.
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "nodegroup_key_name" {
  description = "Kubernetes nodegroup key"
  type = string
  default     = null
}



variable "create_iam_role_nodegroup" {
  description = "Create IAM role for the node group or not"
  type        = bool
  default     = false
}