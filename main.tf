terraform {
  cloud {
    organization = "spa-s3fileupload"
    workspaces {
      name = "internal-spa"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "internal-spa"
      ManagedBy = "terraform"
    }
  }
}
