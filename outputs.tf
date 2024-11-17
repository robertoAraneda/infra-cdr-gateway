output "alb_keycloak_dns_name" {
  description = "The DNS name of the ALB for Keycloak."
  value = module.keycloak_ecs_service.alb_dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value = module.ecs_cluster.cluster
}

output "keycloak_admin_password" {
  description = "The admin password for Keycloak."
  value = random_password.keycloak_admin.result
}

output "keycloak_admin_user" {
  description = "The admin user for Keycloak."
  value = "admin"
}