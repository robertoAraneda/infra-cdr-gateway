variable "ecs_container_insights" {
  description = "Enable container insights"
  type        = string
  default     = "enabled" // "enabled" or "disabled"
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for the ECS cluster"
  type        = map(string)
  default     = {}
}