locals {
  hapi = "${var.project}-${var.environment}-hapi"
}


#########################
# Create Unique password
#########################

resource "random_password" "hapi_master" {
  length           = 16
  special          = false
  override_special = "_!%^"
}

################################################################################
# RDS DB Instance Module
################################################################################

module "hapi_db" {
  source = "./modules/rds_modules/rds_db_instance"

  identifier = "${var.project}-${var.environment}-hapi-db"

  engine         = "postgres"
  engine_version = "15.7"

  instance_class    = "db.t3.large"
  storage_type      = "gp3"
  allocated_storage = 400
  iops              = 12000

  max_allocated_storage = 1000

  db_name  = "hapi"
  username = "admin"
  port     = "5432"
  password = random_password.hapi_master.result

  multi_az = false

  db_subnet_group_name   = module.subnet_group.db_subnet_group_id
  vpc_security_group_ids = [var.default_security_group_id]

  maintenance_window              = "Thu:04:00-Thu:05:00"
  backup_window                   = "02:00-03:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  tags = merge(
    {
      "Name" = "${var.project}-${var.environment}-db"
    },
    var.tags
  )
}

################################################################################
# Task Definition Module
################################################################################

module "hapi_task_definition" {
  source = "./modules/ecs_modules/ecs_task_definition"

  family          = local.hapi
  container_name  = local.hapi
  container_image = "hapiproject/hapi:v7.4.0"
  container_ports = [8080]
  environment = [
    {
      name  = "DB_URL"
      value = "jdbc:postgresql://${module.hapi_db.db_instance_address}:${module.hapi_db.db_instance_port}/${module.hapi_db.db_instance_name}"
    },
    {
      name  = "DB_USERNAME"
      value = module.hapi_db.db_instance_username
    },
    {
      name  = "DB_PASSWORD"
      value = random_password.hapi_master.result
    },
    {
      name  = "SERVER_URL"
      value = "https://gateway.onfhir.cl"
    }
  ]
  memory = "4096"
  cpu    = "1024"

  log_group_name = "/ecs/${var.project}-${var.environment}/hapi"

  tags = var.tags
}


################################################################################
# ECS Service Module
################################################################################

module "hapi_ecs_service" {
  source = "./modules/ecs_modules/ecs_service"

  //cluster
  cluster_id = module.ecs_cluster.cluster_id
  vpc_id     = var.vpc_id

  //service
  task_definition_arn = module.hapi_task_definition.task_definition_arn
  name                = local.hapi
  subnet_ids          = var.private_subnet_ids

  health_check_grace_period_seconds = 300
  //load balancer
  load_balancer = {
    internal   = true
    name       = local.hapi
    subnet_ids = var.private_subnet_ids
    type       = "application"

    target_group = {
      name = local.hapi
      port = 8080
      health_check = {
        path = "/baseR4/actuator/health"
      }
    }
    listeners = {
      http = {
        enabled     = true
        action_type = "forward"
      }
      https = {
        enabled = false
      }
    }
  }
  tags = var.tags
}

################################################################################
# Cloudwatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "hapi_logs" {
  name              = "/ecs/${var.project}-${var.environment}/hapi"
  retention_in_days = 7
  tags              = var.tags
}