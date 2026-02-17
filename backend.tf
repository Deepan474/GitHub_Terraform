terraform {
  backend "s3" {
    bucket = "statefile-deep"
    key    = "demo.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}