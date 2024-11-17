output "alb_keycloak_dns_name" {
  description = "The DNS name of the ALB for Keycloak."
  value       = module.keycloak_ecs_service.alb_dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.ecs_cluster.cluster
}

output "keycloak_admin_password" {
  description = "The admin password for Keycloak."
  value       = random_password.keycloak_admin.result
}

output "keycloak_admin_user" {
  description = "The admin user for Keycloak."
  value       = "admin"
}

output "kong_db_password" {
  description = "The password for the Kong database."
  value       = random_password.kong_master.result
  sensitive = true
}

output "kong_db_username" {
  description = "The username for the Kong database."
  value       = module.kong_db.db_instance_username
}

output "kong_db_host" {
  description = "The host for the Kong database."
  value       = module.kong_db.db_instance_address
}