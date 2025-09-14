output "alb_dns_name" {
  description = "DNS público del ALB (URL base de la API)"
  value       = aws_cloudformation_stack.api.outputs["ALBDNSName"]
}

output "cluster_name" {
  value = aws_cloudformation_stack.api.outputs["ClusterName"]
}

output "service_name" {
  value = aws_cloudformation_stack.api.outputs["ServiceName"]
}
