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
