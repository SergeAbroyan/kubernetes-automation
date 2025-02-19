# outputs.tf - Outputs SSH Key Pair information

output "key_name" {
  description = "Key Pair name"
  value       = aws_key_pair.k8s_key_pair.key_name
}
