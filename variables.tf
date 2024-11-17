variable "region" {
  description = "The region in which the resources will be created."
  default     = "us-east-2"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default = {
    Project     = "conectathon"
    Environment = "dev"
    CreatedBy   = "robaraneda@gmail.com"
  }
}

variable "project" {
  description = "The project name."
  default     = "conectathon" 
}

variable "environment" {
  description = "The environment name."
  default     = "dev"
}

variable "default_security_group_id" {
  description = "The default security group ID."
  type = string
  default = "sg-1"
}

variable "vpc_id" {
  description = "The VPC ID to deploy resources"
  default     = "vpc-1" // VPC ID on dev
}

variable "private_subnet_ids" {
  description = "The Subnet IDs to deploy resources"
  type        = list(string)
  default     = ["subnet-1", "subnet-2"] // Subnet IDs on dev
}

variable "public_subnet_ids" {
  description = "The Subnet IDs to deploy resources"
  type        = list(string)
  default     = ["subnet-1", "subnet-2"] // Subnet IDs on dev
}
