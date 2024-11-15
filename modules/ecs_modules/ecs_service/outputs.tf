output "load_balancer_dns" {
  value       = aws_lb.this.dns_name
  description = "The DNS name of the load balancer"
}

output "load_balancer_arn" {
  value       = aws_lb.this.arn
  description = "The ARN of the load balancer"
}

output "load_balancer_id" {
  value       = aws_lb.this.id
  description = "The ID of the load balancer"
}

output "aws_security_group_ecs_service_id" {
  value       = aws_security_group.ecs_service.id
  description = "The ID of the security group for the ECS service"
}

output "aws_security_group_load_balancer_id" {
  value       = aws_security_group.load_balancer.id
  description = "The ID of the security group for the load balancer"
}

output "aws_lb_target_group_id" {
  value       = aws_lb_target_group.this.id
  description = "The ID of the target group"
}

output "aws_lb_target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "The ARN of the target group"
}

