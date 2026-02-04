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

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]
    content {
      enabled = lookup(access_logs.value, "enabled", null)
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
  vpc_id      = lookup(each.value, "vpc_id", null)

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

resource "aws_lb_listener" "this" {
  for_each = { for idx, entry in var.listeners : tostring(idx) => entry }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = lookup(each.value, "ssl_policy", null)
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
