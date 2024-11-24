output "aws_security_group_ecs_service_id" {
  value       = aws_security_group.ecs_service.id
  description = "The ID of the security group for the ECS service"
}

output "aws_security_group_load_balancer_id" {
  value       = aws_security_group.load_balancer.id
  description = "The ID of the security group for the load balancer"
}

output "load_balancer_dns" {
  value = { for lb_name, lb in aws_lb.this : lb_name => lb.dns_name }
  description = "A map of DNS names for each load balancer"
}