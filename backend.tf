terraform {
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
}
  backend "s3" {
    bucket = "statefile-deep"
    key    = "demo.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
  required_version = "~> 1.10"
}