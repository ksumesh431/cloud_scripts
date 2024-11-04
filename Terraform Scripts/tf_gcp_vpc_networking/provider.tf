{
  "version": 4,
  "terraform_version": "1.2.7",
  "serial": 3,
  "lineage": "392bd177-0ed5-cae2-7be6-c88e090ee83b",
  "outputs": {},
  "resources": []
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.31.0"
    }
  }
}


provider "google" {
  # Configuration options
  project     = "impactful-shard-362913"
  region      = "asia-south2"
  zone        = "asia-south2-a"
  credentials = "keys.json"
}