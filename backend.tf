terraform {
  backend "s3" {
    bucket         = "conectaton-2025-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "conectaton-2025-state"
  }
}