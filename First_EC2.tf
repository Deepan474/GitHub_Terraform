provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-0c1fe732b5494dc14"
    instance_type = "t2.micro"
}