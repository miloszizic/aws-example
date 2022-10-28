provider "aws" {
  region = var.region
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.34.0"
    }
  }
  backend "s3" {
    bucket     = "s3-remote-state-20221018154517921000000001"
    key        = "state/terraform.tfstate"
    region     = "us-east-1"
    encrypt    = true
    kms_key_id = "alias/terraform-bucket-key"
  }
}
