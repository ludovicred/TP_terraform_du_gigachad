terraform {

  backend "s3" {
    bucket = "kfcpourterraform"
    /*key = "dev/terraform.tfstate"*/
    region       = "us-east-1"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}