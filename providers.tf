terraform {
  required_version = "~> 1.2.7"
  required_providers {
    aws = "~> 4.0"
  }
}

provider "aws" {
  region = var.aws_region
}