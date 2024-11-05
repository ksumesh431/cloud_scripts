# Terraform EKS Deployment with Argo CD Integration

This Terraform configuration provisions an Amazon EKS (Elastic Kubernetes Service) cluster along with an autoscaler and Argo CD for continuous deployment. The infrastructure is modularized to facilitate easy management and scalability.

## Resources Created

- **VPC**: A Virtual Private Cloud that hosts the EKS cluster and associated resources.
- **EKS Cluster**: An Elastic Kubernetes Service cluster with the specified Kubernetes version.
- **IAM Roles**: IAM roles for user authentication and authorization within the cluster.
- **EKS Autoscaler**: An autoscaler for managing the number of worker nodes dynamically based on resource requirements.
- **Argo CD**: A continuous deployment tool installed on the EKS cluster to manage applications.

## Configuration Overview

### VPC Module

The VPC module is responsible for creating the necessary networking infrastructure. It is defined as follows:

```hcl
module "vpc" {
  source  = "./modules/vpc"
  product = var.product
}
```

### EKS Module

The EKS module creates an EKS cluster configured with the specified version and integrates with the VPC:

```hcl
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
```

### EKS Autoscaler Module

The autoscaler module ensures the cluster can dynamically adjust its capacity based on the current workload. It contains the policy for autoscaler. we can deploy the cluster autoscaler use helm charts:

```hcl
module "eks_autoscaler" {
  source            = "./modules/eks-autoscaler"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint   = module.eks.cluster_endpoint
}
```

### Argo CD Integration

Argo CD is set up for continuous deployment using Helm charts. The module for deploying Argo CD is defined as follows:

```hcl
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
```

## Authentication Configuration

To authenticate with the EKS cluster, the following data sources are used to retrieve necessary credentials:

```hcl
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
```

## Usage

1. **Initialize Terraform**: Run the following command to initialize the Terraform workspace and download the necessary providers.

   ```bash
   terraform init
   ```

2. **Review the Plan**: Check the changes Terraform will make to your infrastructure:

   ```bash
   terraform plan
   ```

3. **Apply the Configuration**: Provision the infrastructure:

   ```bash
   terraform apply
   ```

4. **Access Argo CD**: Once the infrastructure is set up, access Argo CD via its endpoint to manage your applications.

## Conclusion

This Terraform setup automates the provisioning of an EKS cluster along with Argo CD, allowing for a seamless CI/CD experience in managing Kubernetes applications. Customize the modules further as needed to fit your specific use case.
