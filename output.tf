output "private_key" {
  description = "Private key to SSH to the server"
  value       = tls_private_key.pavlov.private_key_pem
  sensitive   = true
}

output "ec2_global_ip" {
  description = "Public IP address of the server"
  value       = aws_instance.pavlov.public_ip
}