output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id"{
  value = module.vpc.vpc_id  
}

output "additional_cidr_blocks" {
  description = "A list of the additional IPv4 CIDR blocks associated with the VPC"
  value       = module.vpc.additional_cidr_blocks
}

output "additional_cidr_blocks_to_association_ids" {
  description = "A map of the additional IPv4 CIDR blocks to VPC CIDR association IDs"
  value       = module.vpc.additional_cidr_blocks_to_association_ids
}


output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.subnets.public_subnet_ids
}



output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.subnets.private_subnet_ids
}



output "vpc_ipv6_association_id" {
  value       = module.vpc.vpc_ipv6_association_id
  description = "The association ID for the primary IPv6 CIDR block"
}

output "vpc_ipv6_cidr_block" {
  value       = module.vpc.vpc_ipv6_cidr_block
  description = "The primary IPv6 CIDR block"
}

output "ipv6_cidr_block_network_border_group" {
  value       = module.vpc.ipv6_cidr_block_network_border_group
  description = "The Network Border Group Zone name"
}


output "vpc_default_security_group_id" {
  value = module.vpc.vpc_default_security_group_id
}
