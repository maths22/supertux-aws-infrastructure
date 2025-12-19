terraform {
  cloud {
    organization = "maths22"

    workspaces {
      name = "supertux-aws-infrastructure"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project = "Supertux"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}