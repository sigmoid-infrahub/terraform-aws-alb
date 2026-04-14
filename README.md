# Module: ALB

This module creates and manages an AWS Application Load Balancer (ALB), including target groups and listeners.

## Features
- Create Application Load Balancer (Internal or External)
- Configure Listeners (HTTP/HTTPS)
- Manage Target Groups
- Support for Access Logs
- Custom Security Groups and Subnets

## Usage
```hcl
module "alb" {
  source = "../../terraform-modules/terraform-aws-alb"

  name               = "my-alb"
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]
}
```

## Inputs
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | n/a | Load balancer name |
| `load_balancer_type` | `string` | n/a | Load balancer type |
| `internal` | `bool` | `false` | Internal load balancer |
| `subnets` | `list(string)` | n/a | Subnet IDs |
| `security_groups` | `list(string)` | `[]` | Security group IDs |
| `enable_deletion_protection` | `bool` | `false` | Enable deletion protection |
| `enable_cross_zone_load_balancing` | `bool` | `true` | Enable cross-zone load balancing |
| `idle_timeout` | `number` | `60` | Idle timeout |
| `enable_http2` | `bool` | `true` | Enable HTTP/2 |
| `drop_invalid_header_fields` | `bool` | `false` | Drop invalid header fields |
| `access_logs` | `any` | `null` | Access log configuration |
| `listeners` | `any` | `[]` | Listeners configuration |
| `target_groups` | `any` | `[]` | Target groups configuration |
| `tags` | `map(string)` | `{}` | Tags to apply |

## Outputs
| Name | Description |
|------|-------------|
| `lb_arn` | Load balancer ARN |
| `dns_name` | Load balancer DNS name |
| `module` | Full module outputs |

## Environment Variables
None

## Notes
- Ensure that the subnets provided are in different Availability Zones for high availability.
- Security groups must allow traffic on the listener ports.
