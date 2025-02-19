# outputs.tf - Outputs IAM role details

output "control_plane_role" {
  description = "IAM role for Kubernetes control plane"
  value       = aws_iam_role.k8s_control_plane.arn
}

output "worker_nodes_role" {
  description = "IAM role for Kubernetes worker nodes"
  value       = aws_iam_role.k8s_worker_nodes.arn
}

output "karpenter_role" {
  description = "IAM role for Karpenter"
  value       = aws_iam_role.karpenter.arn
}
