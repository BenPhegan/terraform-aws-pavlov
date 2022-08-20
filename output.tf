output "private_key" {
  value     = tls_private_key.pavlov.private_key_pem
  sensitive = true
}