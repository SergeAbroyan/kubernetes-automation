# outputs.tf - Outputs Kubernetes cluster details

output "kubeconfig" {
  description = "Kubeconfig file for cluster access"
  value       = "/home/ubuntu/.kube/config"
}

output "control_plane_ip" {
  description = "Public IP of the control plane node"
  value       = var.control_plane_ip
}
