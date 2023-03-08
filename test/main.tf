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
  prefix = local.project
}

locals {
  project       = "scrooge-resource-test"
  workspace_tag = "test"
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
