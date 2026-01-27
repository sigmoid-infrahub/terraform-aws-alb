output "lb_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "Load balancer DNS name"
  value       = aws_lb.this.dns_name
}

output "module" {
  description = "Full module outputs"
  value = {
    lb_arn   = aws_lb.this.arn
    dns_name = aws_lb.this.dns_name
  }
}
