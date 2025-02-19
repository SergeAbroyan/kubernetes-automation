output "control_plane_id" {
  description = "ID of the EC2 instance running the Kubernetes control plane"
  value       = aws_instance.control_plane.id
}

output "control_plane_ip" {
  description = "Public IP of the control plane instance"
  value       = aws_instance.control_plane.public_ip
}

output "worker_node_ids" {
  description = "IDs of the Kubernetes worker nodes"
  value       = aws_instance.worker_nodes[*].id
}

output "worker_node_ips" {
  description = "Public IPs of the worker nodes"
  value       = aws_instance.worker_nodes[*].public_ip
}
