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
  default     = false
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
  default     = false
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

variable "target_groups" {
  type        = any
  description = "Target groups configuration"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
