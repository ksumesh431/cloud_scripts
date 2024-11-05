module "vpc" {
  source  = "./modules/vpc"
  product = var.product
}


module "eks" {
  source            = "./modules/eks"
  product           = var.product
  cluster_version   = "1.25"
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids
  map_roles = [
    {
      rolearn  = "arn:aws:iam::895884664845:user/eks_user_sumesh"
      username = "eks_user_sumesh"
      groups   = ["system:masters"]
    }
  ]
}


module "eks_autoscaler"{
  source = "./modules/eks-autoscaler"
  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
}



data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}



module "argo_application" {
  source = "lablabs/eks-argocd/aws"

  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = true

  self_managed = false

  helm_release_name = "argocd-helm"
  namespace         = "argocd-helm"

  argo_namespace = "default"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}




