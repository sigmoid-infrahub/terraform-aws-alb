resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  internal           = var.internal

  subnets         = var.subnets
  security_groups = var.security_groups

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  idle_timeout                     = var.idle_timeout
  enable_http2                     = var.enable_http2
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  enable_waf_fail_open             = var.enable_waf_fail_open

  dynamic "access_logs" {
    for_each = try(lookup(var.access_logs, "bucket", null), null) == null ? [] : [var.access_logs]
    content {
      enabled = lookup(access_logs.value, "enabled", true)
      bucket  = access_logs.value.bucket
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  tags = local.resolved_tags
}

resource "aws_lb_target_group" "this" {
  for_each = { for entry in var.target_groups : entry.name => entry }

  name        = each.value.name
  port        = each.value.backend_port
  protocol    = each.value.backend_protocol
  target_type = each.value.target_type
  vpc_id      = coalesce(lookup(each.value, "vpc_id", null), var.vpc_id)

  dynamic "health_check" {
    for_each = lookup(each.value, "health_check", null) == null ? [] : [each.value.health_check]
    content {
      enabled             = lookup(health_check.value, "enabled", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      interval            = lookup(health_check.value, "interval", null)
    }
  }

  tags = local.resolved_tags
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = local.target_group_attachments

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}

resource "aws_acm_certificate" "alb" {
  count = var.domain_name != null && var.create_acm_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.resolved_tags
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = var.domain_name != null && var.create_acm_certificate ? {
    for dvo in aws_acm_certificate.alb[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "alb" {
  count = var.domain_name != null && var.create_acm_certificate ? 1 : 0

  certificate_arn = aws_acm_certificate.alb[0].arn
  validation_record_fqdns = [
    for record in aws_route53_record.alb_cert_validation : record.fqdn
  ]
}

resource "aws_lb_listener" "this" {
  for_each = { for idx, entry in var.listeners : tostring(idx) => entry }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = contains(["HTTPS", "TLS"], each.value.protocol) ? coalesce(lookup(each.value, "ssl_policy", null), var.ssl_policy) : null
  certificate_arn   = lookup(each.value, "certificate_arn", null)

  default_action {
    type = each.value.default_action.type

    dynamic "redirect" {
      for_each = lookup(each.value.default_action, "redirect", null) == null ? [] : [each.value.default_action.redirect]
      content {
        port        = lookup(redirect.value, "port", null)
        protocol    = lookup(redirect.value, "protocol", null)
        status_code = lookup(redirect.value, "status_code", null)
      }
    }

    dynamic "forward" {
      for_each = lookup(each.value.default_action, "target_group_key", null) == null ? [] : [each.value.default_action]
      content {
        target_group {
          arn = aws_lb_target_group.this[forward.value.target_group_key].arn
        }
      }
    }
  }
}

resource "aws_lb_listener" "http" {
  count = var.default_target_group_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.default_target_group_arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.domain_name != null && var.default_target_group_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.default_target_group_arn
  }
}
