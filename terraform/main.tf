terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  backend "s3" {
    key    = "state"
    region = "eu-west-2"
  }
}

locals {
  is_test = terraform.workspace == "test"
  prefix  = terraform.workspace == "test" ? "${local.project}-test" : local.project
}

locals {
  project       = "scrooge"
  workspace_tag = local.is_test ? "test" : "dev"
  tier          = "platform"
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project   = local.project
      Workspace = local.workspace_tag
      Tier      = local.tier
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.scrooge_repo.registry_id
}
