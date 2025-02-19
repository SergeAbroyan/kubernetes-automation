# outputs.tf - Outputs important Load Balancer details

output "alb_dns_name" {
  description = "DNS Name of the Application Load Balancer"
  value       = aws_lb.k8s_alb.dns_name
}
