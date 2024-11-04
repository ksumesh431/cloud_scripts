# Terraform EKS, VPC, and ArgoCD Helm Deployment

This Terraform configuration provisions an AWS EKS cluster and associated VPC, along with deploying ArgoCD using Helm. It also includes an autoscaling configuration for attaching Auto Scaling groups to load balancer target groups.

## Prerequisites

- **Terraform**: Ensure Terraform is installed. You can download it from [Terraform Downloads](https://www.terraform.io/downloads).
- **AWS CLI**: AWS CLI is required to update the kubeconfig for accessing the EKS cluster. Ensure it's installed and configured.
- **Helm**: Helm is used for managing the ArgoCD deployment.
- **AWS Credentials**: Your AWS credentials should be configured via environment variables or in the `~/.aws/credentials` file.

## Usage

1. Clone the repository and navigate to the project directory.
2. Ensure your AWS credentials and configuration are set up properly.
3. Modify any variable values if needed, especially `aws_auth_roles`, `vpc_cidr`, and tags.
4. Run the following commands to initialize and apply the infrastructure:

```bash
terraform init     # Initialize Terraform providers and modules
terraform plan     # Preview the changes to be applied
terraform apply    # Apply the infrastructure changes
```

## Components

### Local Variables

```hcl
locals {
  name   = "skp-${replace(basename(path.cwd), "_", "-")}"
  region = "us-east-1"
  tags = {
    Environment = "dev"
    CommonTag   = "${local.name}-common-tag"
  }
}
```

- **name**: A dynamic name based on the current directory name, used for naming resources.
- **region**: AWS region where the resources are deployed (`us-east-1`).
- **tags**: Tags applied to resources, including `Environment` and a common tag with the project name.

### EKS Module

```hcl
module "eks" {
  source          = "./modules/eks"
  name            = local.name
  cluster_version = "1.27"
  aws_auth_roles  = var.aws_auth_roles
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  intra_subnets   = module.vpc.intra_subnets
}
```

- **source**: Path to the custom EKS module.
- **name**: The name of the EKS cluster.
- **cluster_version**: EKS version to be deployed (`1.27`).
- **aws_auth_roles**: IAM roles for Kubernetes RBAC authorization (input via `var.aws_auth_roles`).
- **vpc_id**: Uses the VPC created by the VPC module.
- **subnets**: Private and intra subnets where the EKS cluster is deployed.

### VPC Module

```hcl
module "vpc" {
  source                  = "./modules/vpc"
  name                    = local.name
  vpc_cidr                = var.vpc_cidr
  oidc_provider_arn       = module.eks.oidc_provider_arn
  eks_managed_node_groups = module.eks.eks_managed_node_groups
}
```

- **source**: Path to the custom VPC module.
- **vpc_cidr**: CIDR block for the VPC (input via `var.vpc_cidr`).
- **oidc_provider_arn**: OIDC provider ARN from the EKS module.
- **eks_managed_node_groups**: Managed node groups from the EKS module for worker nodes.

### ArgoCD Helm Deployment

```hcl
module "argo_application" {
  source = "./modules/eks-argocd-helm"
  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  helm_force_update                = true
  helm_release_name                = "argocd-helm"
  namespace                        = "argocd-helm"
  argo_namespace                   = "default"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}
```

- **Helm Release**: Deploys ArgoCD via Helm in the `argocd-helm` namespace.
- **OIDC Provider**: Uses the EKS cluster OIDC provider for secure communication.
- **ArgoCD Sync Policy**: Enables automated syncing and namespace creation.

### EKS Kubeconfig Update

```hcl
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }
  depends_on = [module.eks]
}
```

- **Purpose**: Automatically updates your `kubeconfig` to interact with the provisioned EKS cluster using `aws eks update-kubeconfig`.

### Autoscaling Attachment

```hcl
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}
```

- **Purpose**: Attaches the Auto Scaling group to the specified Load Balancer target group for load balancing across nodes in the EKS cluster.

## Variables

- **vpc_cidr**: CIDR block for the VPC (e.g., `"10.0.0.0/16"`).
- **aws_auth_roles**: List of IAM roles with Kubernetes access (e.g., system masters group for admin users).

## Outputs

After running `terraform apply`, you can retrieve the following outputs:

- **VPC ID**: The ID of the created VPC.
- **EKS Cluster Name**: The name of the created EKS cluster.
- **ArgoCD Helm Release**: Helm release information for the ArgoCD deployment.

## Clean-Up

To destroy the resources and clean up the environment, run:

```bash
terraform destroy
```

This will remove all AWS resources provisioned by this configuration.