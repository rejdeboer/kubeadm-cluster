terraform {
  backend "s3" {
    bucket = "rejdeboerrterraform"
    key    = "kubeadm/production"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}
