terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      CreatedBy = "Terraform"
      Purpose   = "POC"
    }
  }
}
