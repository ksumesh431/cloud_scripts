locals {
  name   = "${var.product}-eks-cluster"
  region = var.aws_region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name    = local.name
    Product = var.product
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"
  cluster_name = local.name
  cluster_version  = var.cluster_version
  cluster_endpoint_public_access = var.enable_cluster_endpoint_public_access
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_id
  manage_aws_auth_configmap = true
  aws_auth_roles = var.map_roles
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_irsa = true
  
  #cluster_addons = {
    # coredns = {
    #   preserve    = true
    #   most_recent = true

    #   timeouts = {
    #     create = "25m"
    #     delete = "10m"
    #   }
    # }
    # kube-proxy = {
    #   most_recent = true
    # }
    # vpc-cni = {
    #   most_recent = true
    # }
  #}

  #aws_auth_roles = []
  #var.map_roles
  #[
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    # {
    #   rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
    #   username = "system:node:{{EC2PrivateDNSName}}"
    #   groups = [
    #     "system:bootstrappers",
    #     "system:nodes",
    #   ]
    # },
  #]

  # fargate_profiles = {
  #   karpenter = {
  #     selectors = [
  #       { namespace = "karpenter" }
  #     ]
  #   }
  #   kube_system = {
  #     name = "kube-system"
  #     selectors = [
  #       { namespace = "kube-system" }
  #     ]
  #   }
  # }  

  tags = local.tags
}

#Additional role policy
resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "ondemand-node-group"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  subnet_ids                        = var.private_subnet_id
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]
  min_size     = 1
  max_size     = 10
  desired_size = 1
  # Only create the IAM role policy attachment if create_iam_role is true
  # Otherwise, omit this resource block entirely


  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  ami_type = "AL2_x86_64"

  create_iam_role          = true
  iam_role_name            = "eks-node-group-role"
  iam_role_use_name_prefix = false
  iam_role_description     = "EKS managed node group complete example role"
  iam_role_tags = {
    Purpose = "Protector of the kubelet"
    }
  iam_role_additional_policies = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    AmazonEKSWorkerNodePolicy      = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonCNIPolicy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonSSMIntancePolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    additional                         = aws_iam_policy.node_additional.arn
  }
  #key_name = var.nodegroup_key_name
  # taints = {
  #   dedicated = {
  #     key    = "dedicated"
  #     value  = "gpuGroup"
  #     effect = "NO_SCHEDULE"
  #   }
  # }
  tags = merge(local.tags, { Separate = "eks-managed-node-group" })
}