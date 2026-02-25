output "public_ip" {
  value = aws_instance.myec2.public_ip
}

output "instance_id" {
  value = aws_instance.myec2.id
}