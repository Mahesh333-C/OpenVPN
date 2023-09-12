output "SCP_Command" {
  description = "SCP command to copy a file using the public IP address "
  value       = "scp -i \"mykeypair.pem\" ubuntu@${aws_instance.public_instance.public_ip}:~/client.ovpn ."
}

output "SSH_Command" {
  description = "SSH command to connect to private instance "
  value       = "ssh -i \"mykeypair.pem\" ubuntu@${aws_instance.private_instance.private_ip}"
}

output "key" {
  sensitive = true
  description = "keypair for instances"
  value       = tls_private_key.key_pair.private_key_pem
}