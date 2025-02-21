# outputs.tf - Outputs IAM role details

output "control_plane_instance_profile" {
  value = aws_iam_instance_profile.k8s_control_plane.name
}

output "worker_nodes_instance_profile" {
  value = aws_iam_instance_profile.k8s_worker_nodes.name
}



output "karpenter_role" {
  description = "IAM role for Karpenter"
  value       = aws_iam_role.karpenter.arn
}
