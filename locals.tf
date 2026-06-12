locals {
  sigmoid_tags = merge(
    var.sigmoid_environment != "" ? { "sigmoid:environment" = var.sigmoid_environment } : {},
    var.sigmoid_project != "" ? { "sigmoid:project" = var.sigmoid_project } : {},
    var.sigmoid_team != "" ? { "sigmoid:team" = var.sigmoid_team } : {},
  )


  resolved_tags = merge({
    ManagedBy = "sigmoid"
  }, var.tags, local.sigmoid_tags)

  resolved_security_groups = var.create_security_group ? concat(var.security_groups, [aws_security_group.this[0].id]) : var.security_groups

  acm_certificate_arn = (
    var.domain_name == null ? null :
    var.create_acm_certificate ? aws_acm_certificate_validation.alb[0].certificate_arn : var.acm_certificate_arn
  )

  target_group_attachments = merge([
    for tg in var.target_groups : {
      for idx, instance_id in var.target_instance_ids :
      "${tg.name}.${idx}" => {
        target_group_name = tg.name
        instance_id       = instance_id
        port              = tg.backend_port
      }
    }
  ]...)
}
