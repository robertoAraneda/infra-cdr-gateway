variable "terraform_state_name" {
  description = "The name of the S3 bucket to be created for storing Terraform state"
  type        = string
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default = {
    Project = "tf-infra-state-demo"
  }
}