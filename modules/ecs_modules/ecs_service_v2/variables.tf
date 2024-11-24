### ECS Service Variables

variable "name" {
  description = "The name of the service"
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "The ID of the cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "The ARN of the task definition"
  type        = string
  default     = ""
}

variable "launch_type" {
  description = "The launch type of the service"
  type        = string
  default     = "FARGATE"
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "health_check_grace_period_seconds" {
  description = "The period of time, in seconds, that the Amazon ECS service scheduler should ignore unhealthy Elastic Load Balancing target health checks after a task has first started"
  type        = number
  default     = 60
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "When true, the task or service will be assigned a public IP address"
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "The load balancer configuration"

  type = list(object({
    name       = string
    type       = string
    subnet_ids = list(string)
    internal   = bool
    target_group = object({
      name = string
      port = number
      health_check = object({
        path = string
        port = optional(number)
      })
    })

    listeners = object({
      http = object({
        enabled     = bool
        action_type = optional(string)
      })
      https = object({
        enabled         = bool
        action_type     = optional(string)
        certificate_arn = optional(string)
      })
    })
  }))
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "tags" {
  description = "The tags for the service"
  type        = map(string)
  default     = {}
}
