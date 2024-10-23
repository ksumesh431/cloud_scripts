provider "aws" {
  region = var.aws_region
}

# Alias required for public ECR where Karpenter artifacts are hosted
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

