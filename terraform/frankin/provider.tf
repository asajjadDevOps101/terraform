terraform {
  required_providers {
    aws = "~> 4.35.0"
  }
}


provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "Line of Business" = var.required_tags.LineOfBusiness
    }
  }
}
