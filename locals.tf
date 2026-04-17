locals {
  sigmoid_tags = merge(
    var.sigmoid_environment != "" ? { "sigmoid:environment" = var.sigmoid_environment } : {},
    var.sigmoid_project != "" ? { "sigmoid:project" = var.sigmoid_project } : {},
    var.sigmoid_team != "" ? { "sigmoid:team" = var.sigmoid_team } : {},
  )


  resolved_tags = merge({
    ManagedBy = "sigmoid"
  }, var.tags, local.sigmoid_tags)

  acm_certificate_arn = (
    var.domain_name == null ? null :
    var.create_acm_certificate ? aws_acm_certificate_validation.alb[0].certificate_arn : var.acm_certificate_arn
  )
}
