terraform {
  cloud {
    organization = "push-scheduler"
    workspaces {
      name = "push-scheduler-infra"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-2"
  # profile = "shopee-push-manager"
}

provider "archive" {}
