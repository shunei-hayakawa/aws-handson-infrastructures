terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }

  backend "s3" {
    bucket = "aws-handson-b958eh3n"
    key    = "v1"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  profile = "aws-handson"
}
