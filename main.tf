provider "aws" {
  region     = var.aws_region
}

#data "aws_vpc" "default" {
 # default = true
#}

resource "aws_vpc" "My_VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "My-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = us-east-1a

  tags = {
    Name = "My-Public-Subnet"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.My_VPC.id

  tags = {
    Name = "My-Internet-Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.My_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "My-Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "SG_Demo" {
  name        = "var.security_group_name"
  description = "Managed from Terraform"
  vpc_id      = aws_vpc.My_VPC.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }    
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

resource "aws_instance" "myec2" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.SG_Demo.id]
    associate_public_ip_address = true

    user_data = file("user_data.sh")
        
      tags = {
        Name = var.instance_name
    }
}

resource "aws_eip" "IP" {
  domain   = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.myec2.id
  allocation_id = aws_eip.IP.id
} 