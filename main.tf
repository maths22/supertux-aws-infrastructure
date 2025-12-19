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