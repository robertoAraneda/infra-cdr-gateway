variable "region" {
  description = "The region in which the resources will be created."
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default = {
    Project     = "conectaton-hl7"
    Environment = "dev"
    CreatedBy   = "robaraneda@gmail.com"
  }
}

variable "project" {
  description = "The project name."
  default     = "conectaton-hl7"
}

variable "environment" {
  description = "The environment name."
  default     = "dev"
}


variable "vpc_id" {
  description = "The VPC ID to deploy resources" // VPC ID on dev
}

variable "private_subnet_ids" {
  description = "The Subnet IDs to deploy resources"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The Subnet IDs to deploy resources"
  type        = list(string)
}

variable "monitoring_role_arn" {
  description = "The ARN of the monitoring role"
  type = string
}
