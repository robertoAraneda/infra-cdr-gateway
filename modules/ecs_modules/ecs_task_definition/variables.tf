variable "family" {
  description = "The family of the task definition"
  type        = string
  default     = ""
}

variable "container_name" {
  description = "The name of the container definition"
  type        = string
  default     = ""

}

variable "container_image" {
  description = "The image of the container definition"
  type        = string
  default     = ""
}

variable "container_ports" {
  description = "The port of the container definition"
  type        = list(number)
}

variable "environment" {
  description = "The environment of the task definition"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "command" {
  description = "The command of the task definition"
  type        = list(string)
  default     = []
}

variable "execution_role_arn" {
  description = "The ARN of the task execution role"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "The ARN of the task role"
  type        = string
  default     = ""
}

variable "cpu" {
  description = "The CPU for the task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "The memory for the task"
  type        = number
  default     = 512
}

variable "requires_compatibilities" {
  description = "The compatibility of the task definition"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "network_mode" {
  description = "The network mode of the task definition"
  type        = string
  default     = "awsvpc"

}

variable "ecs_role_policy_arn_attachment" {
  description = "The ARN of the policy to attach to the ECS role"
  type        = string
  default     = ""
}

variable "ecs_role_policy_arn_attachment_enabled" {
  description = "Whether to attach the policy to the ECS role"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "The name of the log group"
  type        = string
  default     = ""
}

variable "create_task_role" {
  description = "Whether to create the task role"
  type        = bool
  default     = false
}

variable "create_execution_role" {
  description = "Whether to create the execution role"
  type        = bool
  default     = false
}

variable "create_task_definition" {
  description = "Whether to create the task definition"
  type        = bool
  default     = true
}

variable "tags" {
  description = "The tags for the task definition"
  type        = map(string)
  default     = {}
}