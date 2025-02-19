# outputs.tf - Outputs Karpenter status

output "karpenter_status" {
  description = "Karpenter installation status"
  value       = helm_release.karpenter.status
}
