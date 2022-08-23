output "private_key" {
  description = "Private key to SSH to the server"
  value       = tls_private_key.pavlov.private_key_pem
  sensitive   = true
}

output "ec2_global_ip" {
  description = "Public IP address of the server"
  value       = aws_instance.pavlov.public_ip
}

output "rcon_password_md5_hash" {
  description = "MD5 hash of the rcon password, ready for use"
  value       = md5(var.rcon_password)
  sensitive   = true
}