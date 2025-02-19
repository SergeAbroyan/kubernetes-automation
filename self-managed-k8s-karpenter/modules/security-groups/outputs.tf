# outputs.tf - Outputs Security Group IDs

output "k8s_nodes_sg" {
  description = "Security Group ID for Kubernetes nodes"
  value       = aws_security_group.k8s_nodes.id
}

output "load_balancer_sg" {
  description = "Security Group ID for Load Balancer"
  value       = aws_security_group.load_balancer.id
}
