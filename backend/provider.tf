terraform {
  required_version = ">= 0.14.9"
  required_providers {
    aws = {
      version = ">= 4.9.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "YOUR_CLI_PROFILE"
  region  = "us-east-1"
  alias   = "us-east-1"
}
provider "aws" {
  profile = "YOUR_CLI_PROFILE"
  region  = "us-west-1"
  default_tags {
    tags = { Name = var.name }
  }
}