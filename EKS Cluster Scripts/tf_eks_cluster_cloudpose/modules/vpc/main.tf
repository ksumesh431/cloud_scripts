provider "aws" {
  region = var.region
}

# locals {
#   region = var.region
#   cidr_block = "10.0.0.0/16"
#   azs      = 
# }


module "vpc" {
  source                  = "cloudposse/vpc/aws"
  ipv4_primary_cidr_block = var.cidr_block
  stage = var.stage
  namespace = var.namespace
  # ipv4_additional_cidr_block_associations = {
  #   "172.22.0.0/16" = {
  #     ipv4_cidr_block     = "172.22.0.0/16"
  #     ipv4_ipam_pool_id   = null
  #     ipv4_netmask_length = null
  #   }
  # }
  # ipv4_cidr_block_association_timeouts = {
  #   create = "3m"
  #   delete = "5m"
  # }

  # assign_generated_ipv6_cidr_block = true

  # default_security_group_deny_all = var.default_security_group_deny_all
  # default_route_table_no_routes   = var.default_route_table_no_routes
  # default_network_acl_deny_all    = var.default_network_acl_deny_all

  #context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  availability_zones   = var.availability_zones
  stage = var.stage
  namespace = var.namespace  
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = true
  #nat_instance_enabled = false
  #context = module.this.context
}

# Verify that a disabled VPC generates a plan without errors
# module "vpc_disabled" {
#   source  = "cloudposse/vpc/aws"
#   enabled = false

#   ipv4_primary_cidr_block          = "172.16.0.0/16"
#   assign_generated_ipv6_cidr_block = true

#   context = module.this.context
# }