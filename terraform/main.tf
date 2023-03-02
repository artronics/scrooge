terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3"
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
  project   = "scrooge"
  workspace = "dev"
  tier      = "platform"
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project   = local.project
      Workspace = local.workspace
      Tier      = local.tier
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.scrooge_repo.registry_id
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/${aws_ecr_repository.scrooge_repo.name}"
    username = "AWS"
    password = data.aws_ecr_authorization_token.token.password
  }
}
