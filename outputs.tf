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
  sensitive = true
}

output "keycloak_admin_user" {
  description = "The admin user for Keycloak."
  value       = "admin"
}

output "keycloak_db_host" {
  description = "The host for the Keycloak database."
  value       = module.keycloak_db.db_instance_address
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

output "konga_db_password" {
  description = "The password for the Konga database."
  value       = random_password.konga_master.result
  sensitive = true
}

output "konga_db_username" {
  description = "The username for the Konga database."
  value       = module.konga_db.db_instance_username
}

output "konga_db_host" {
  description = "The host for the Konga database."
  value       = module.konga_db.db_instance_address
}

output "konga_admin_password" {
  description = "The admin password for Konga."
  value       = random_password.konga_master.result
  sensitive = true 
}

output "konga_admin_user" {
  description = "The admin user for Konga."
  value       = "administrator"
}

output "hapi_db_password" {
  description = "The password for the HAPI database."
  value       = random_password.hapi_master.result
  sensitive = true
}

output "hapi_db_username" {
  description = "The username for the HAPI database."
  value       = module.hapi_db.db_instance_username
}

output "hapi_db_host" {
  description = "The host for the HAPI database."
  value       = module.hapi_db.db_instance_address
}