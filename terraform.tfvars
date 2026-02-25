ami_id = "ami-0c1fe732b5494dc14"
instance_type = "t2.micro"
instance_name = "Terraform-EC2"
aws_region = "us-east-1"

security_group_name = "terraform-firewall"

ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
    {
    from_port   = 80
    to_port     = 80        
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }   
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }   
]