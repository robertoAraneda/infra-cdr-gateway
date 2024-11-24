variable "terraform_state_name" {
  description = "The name of the S3 bucket to be created for storing Terraform state"
  type        = string
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default = {
    Project = "conectaton-hl7-2025-infra"
  }
}

variable "region" {
  default     = "us-east-1"
  description = "Region AWS"
  type        = string
}

variable "profile" {
  description = "The AWS profile"
  type        = string
}