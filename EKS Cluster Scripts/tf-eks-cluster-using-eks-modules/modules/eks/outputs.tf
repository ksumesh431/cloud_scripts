output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "cluster_endpoint" {
  description = "The API server endpoint for the Amazon EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
  description = "The ID of the security group associated with the Amazon EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "eks_this" {
  value = module.eks
}