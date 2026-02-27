output "public_ip" {
  value = aws_eip.IP.public_ip
}

output "instance_id" {
  value = aws_instance.myec2.id
}