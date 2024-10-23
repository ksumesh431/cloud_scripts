provider "aws" {
  region                   = var.aws_region
  profile                  = var.profile
  shared_credentials_files = ["../credentials/creds"]
}





