variable "name" {
  type        = string
  description = "Load balancer name"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"
}

variable "internal" {
  type        = bool
  description = "Internal load balancer"
  default     = false
}

variable "subnets" {
  type        = list(string)
  description = "Subnet IDs"
}

variable "security_groups" {
  type        = list(string)
  description = "Security group IDs"
  default     = []
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "Enable cross-zone load balancing"
  default     = true
}

variable "idle_timeout" {
  type        = number
  description = "Idle timeout"
  default     = 60
}

variable "enable_http2" {
  type        = bool
  description = "Enable HTTP/2"
  default     = true
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "Drop invalid header fields"
  default     = true
}

variable "enable_waf_fail_open" {
  type        = bool
  description = "Allow requests to route to targets when AWS WAF is unavailable"
  default     = false
}

variable "access_logs_kms_key_id" {
  type        = string
  description = "KMS key ID used by the access logs bucket. Kept for manifest compatibility; ALB access_logs does not accept a KMS key directly"
  default     = ""
}

variable "access_logs" {
  type        = any
  description = "Access log configuration"
  default     = null
}

variable "listeners" {
  type        = any
  description = "Listeners configuration"
  default     = []
}

variable "domain_name" {
  type        = string
  description = "Primary domain name for ALB TLS certificate"
  default     = null
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for ALB TLS certificate"
  default     = []
}

variable "create_acm_certificate" {
  type        = bool
  description = "Whether to create ACM certificate automatically"
  default     = true
}

variable "acm_certificate_arn" {
  type        = string
  description = "Existing ACM certificate ARN to use when auto-creation is disabled"
  default     = null
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for ACM DNS validation records"
  default     = null
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for managed HTTPS listener"
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  validation {
    condition = (
      startswith(var.ssl_policy, "ELBSecurityPolicy-TLS13-") ||
      startswith(var.ssl_policy, "ELBSecurityPolicy-FS-") ||
      startswith(var.ssl_policy, "ELBSecurityPolicy-TLS-1-2-")
    )
    error_message = "ssl_policy must enforce TLS 1.2 or higher"
  }
}

variable "default_target_group_arn" {
  type        = string
  description = "Default target group ARN used by managed HTTP/HTTPS listeners"
  default     = null
}

variable "target_groups" {
  type        = any
  description = "Target groups configuration"
  default     = []
}

variable "target_instance_ids" {
  type        = list(string)
  description = "EC2 instance IDs to register with target groups (registered against every defined target group)"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "Default VPC ID for target groups when not provided per target group"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}

# ====================================
# Sigmoid Tags Configuration
# ====================================

variable "sigmoid_environment" {
  description = "Sigmoid environment identifier for cost allocation"
  type        = string
  default     = ""
}

variable "sigmoid_project" {
  description = "Sigmoid project identifier for cost allocation"
  type        = string
  default     = ""
}

variable "sigmoid_team" {
  description = "Sigmoid team identifier for cost allocation"
  type        = string
  default     = ""
}
