# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.70"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.7"
    }    
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "eks-bucket"
    key    = "dev/k8-state/terraform.tfstate"
    region = "us-east-2" 

    # For State Locking
    dynamodb_table = "k8-state-table"    
  }     
}
