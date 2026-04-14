locals {
  resolved_tags = merge({
    ManagedBy = "sigmoid"
  }, var.tags)

  acm_certificate_arn = (
    var.domain_name == null ? null :
    var.create_acm_certificate ? aws_acm_certificate_validation.alb[0].certificate_arn : var.acm_certificate_arn
  )
}
