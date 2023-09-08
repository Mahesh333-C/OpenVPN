output "public_instance_ip" {
  description = "Public IP address of the EC2 instance in the public subnet."
  value       = aws_instance.public_instance.public_ip
}

output "private_instance_ip" {
  description = "Private IP address of the EC2 instance in the private subnet."
  value       = aws_instance.private_instance.private_ip
}

output "key" {
  sensitive = true
  description = "keypair for instances"
  value       = tls_private_key.key_pair.private_key_pem
}