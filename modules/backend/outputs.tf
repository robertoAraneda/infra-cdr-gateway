output "bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "The name of the bucket used for Terraform states"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state.name
  description = "The name of the DynamoDB table used for state locking"
}
