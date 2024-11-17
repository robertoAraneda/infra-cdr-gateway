#########################
# Create Unique password
#########################

resource "random_password" "konga_master" {
  length           = 16
  special          = false
  override_special = "_!%^"
}

resource "random_password" "konga_admin" {
  length           = 16
  special          = false
  override_special = "_!%^"
}

################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "kong" {
  domain_name       = "admingw.onfhir.cl"
  validation_method = "DNS"
  tags              = merge(
    {
      "Name" = "admingw.onfhir.cl"
    },
    var.tags
  )
}


#########
# Locals
#########
locals {
  konga = "${var.project}-${var.environment}-konga"
}

################################################################################
# RDS DB Instance Module
################################################################################

module "konga_db" {
  source = "./modules/rds_modules/rds_db_instance"

  identifier = "${var.project}-${var.environment}-konga-db"

  engine         = "mysql"
  engine_version = "8.0.35"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 1000

  db_name  = "konga"
  username = "admin"
  port     = "3306"
  password = random_password.konga_master.result

  multi_az = false

  db_subnet_group_name   = module.subnet_group.db_subnet_group_id
  vpc_security_group_ids = [var.default_security_group_id]

  maintenance_window              = "Thu:04:00-Thu:05:00"
  backup_window                   = "02:00-03:00"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  create_cloudwatch_log_group     = false


  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled = false

  tags = merge(
    {
      "Name" = "${var.project}-${var.environment}-db"
    },
    var.tags
  )
}

module "konga_task_definition" {
  source = "./modules/ecs_modules/ecs_task_definition"

  family          = local.konga
  container_name  = local.konga
  container_image = "pantsel/konga:0.14.9"
  container_ports = [1337]
  environment = [
    {
      name  = "DB_ADAPTER"
      value = "mysql"
    },
    {
      name  = "DB_HOST"
      value = module.konga_db.db_instance_address
    },
    {
      name  = "DB_PORT"
      value = module.konga_db.db_instance_port
    },
    {
      name  = "DB_USER"
      value = module.konga_db.db_instance_username
    },
    {
      name  = "DB_DATABASE"
      value = module.konga_db.db_instance_name
    },
    {
      name  = "DB_PASSWORD"
      value = random_password.konga_master.result
    },
    {
      name  = "KONGA_PORT"
      value = "1337"
    },
    {
      name  = "KONGA_LOG_LEVEL"
      value = "debug"
    },
    {
      name  = "TOKEN_SECRET"
      value = "some_secret_token"
    },
    {
      name  = "NODE_ENV"
      value = "development"
    }
  ]
  memory = "512"
  cpu    = "256"

  log_group_name = "/ecs/${var.project}-${var.environment}/konga"

  tags = var.tags
}


module "konga_ecs_service" {
  source = "./modules/ecs_modules/ecs_service"

  //cluster
  cluster_id = module.ecs_cluster.cluster_id
  vpc_id     = var.vpc_id

  //service
  task_definition_arn = module.konga_task_definition.task_definition_arn
  name                = local.konga
  subnet_ids          = var.private_subnet_ids

  //load balancer
  load_balancer = {
    internal   = false
    name       = local.konga
    subnet_ids = var.public_subnet_ids
    type       = "application"

    target_group = {
      name = local.konga
      port = 1337
      health_check = {
        path = "!/register" #first time
        #path = "/#!/login"
      }
    }
    listeners = {
      http = {
        enabled     = true
        action_type = "forward"
      }
      https = {
        enabled         = true
        action_type     = "forward"
        certificate_arn = data.aws_acm_certificate.konga.arn
      }
    }
  }
  tags = var.tags
}



resource "aws_cloudwatch_log_group" "konga_logs" {
  name              = "/ecs/${var.project}-${var.environment}/konga"
  retention_in_days = 7
  tags              = var.tags
}