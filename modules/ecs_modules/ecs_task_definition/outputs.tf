output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = try(aws_ecs_task_definition.this[0].arn, "")
}

output "task_definition_execution_role_arn" {
  description = "The ARN of the task definition execution role"
  value       = try(aws_iam_role.ecs_task_execution_role[0].arn, "")
}