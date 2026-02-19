provider "aws" {
  region     = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "SG_Demo" {
  name        = "terraform-firewall"
  description = "Managed from Terraform"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.SG_Demo.id
  cidr_ipv4         = "${aws_eip.IP.public_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_Flask_App" {
  security_group_id = aws_security_group.SG_Demo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.SG_Demo.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.myec2.id
  allocation_id = aws_eip.IP.id
} 

resource "aws_instance" "myec2" {
    ami = "ami-0c1fe732b5494dc14"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.SG_Demo.id]
}

resource "aws_eip" "IP" {
  domain   = "vpc"
}