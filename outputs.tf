output "lb_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "Load balancer DNS name"
  value       = aws_lb.this.dns_name
}

output "acm_certificate_arn" {
  description = "Resolved ACM certificate ARN"
  value       = local.acm_certificate_arn
}

output "http_listener_arn" {
  description = "Managed HTTP listener ARN"
  value       = try(aws_lb_listener.http[0].arn, null)
}

output "https_listener_arn" {
  description = "Managed HTTPS listener ARN"
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "default_target_group_arn" {
  description = "First managed target group ARN for simple service integrations"
  value       = try(values(aws_lb_target_group.this)[0].arn, null)
}

output "module" {
  description = "Full module outputs"
  value = {
    lb_arn                   = aws_lb.this.arn
    dns_name                 = aws_lb.this.dns_name
    acm_certificate_arn      = local.acm_certificate_arn
    http_listener_arn        = try(aws_lb_listener.http[0].arn, null)
    https_listener_arn       = try(aws_lb_listener.https[0].arn, null)
    default_target_group_arn = try(values(aws_lb_target_group.this)[0].arn, null)
  }
}
