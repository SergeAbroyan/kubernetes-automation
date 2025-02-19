# outputs.tf - Outputs important EC2 instance details

output "control_plane_id" {
  description = "ID of the Kubernetes control plane instance"
  value       = aws_instance.control_plane.id
}

output "worker_node_ids" {
  description = "IDs of the Kubernetes worker nodes"
  value       = aws_instance.worker_nodes[*].id
}
