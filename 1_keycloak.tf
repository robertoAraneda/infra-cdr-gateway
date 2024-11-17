locals {
  keycloak = "${var.project}-${var.environment}-keycloak"
}

################################################################################
# ACM Certificate
################################################################################
resource "aws_acm_certificate" "keycloak" {
  domain_name       = "auth.onfhir.cl"
  validation_method = "DNS"
  tags              = merge(
    {
      "Name" = "auth.onfhir.cl"
    },
    var.tags
  )
}

#########################
# Create Unique password
#########################
resource "random_password" "keycloak_master" {
  length           = 16
  special          = false
  override_special = "_!%^"
}

resource "random_password" "keycloak_admin" {
  length           = 16
  special          = false
  override_special = "_!%^"
}

################################################################################
# RDS DB Instance Module
################################################################################

module "keycloak_db" {
  source = "./modules/rds_modules/rds_db_instance"

  identifier = "${var.project}-${var.environment}-keycloak-db"

  engine         = "postgres"
  engine_version = "15.7"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 1000

  db_name  = "keycloak"
  username = "kcadmin"
  port     = 5432
  password = random_password.keycloak_master.result

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

// create rds monitoring role
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_role.json
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_role" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_monitoring_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}


################################################################################
# Task Definition Module
################################################################################

module "keycloak_task_definition" {
  source = "./modules/ecs_modules/ecs_task_definition"

  family          = local.keycloak
  container_name  = local.keycloak
  container_image = "quay.io/keycloak/keycloak:24.0.3"
  container_ports = [8080]
  environment = [
    {
      name  = "JAVA_OPTS_APPEND"
      value = "-Dkeycloak.profile.feature.upload_scripts=enable"
    },
    {
      name  = "KC_DB_PASSWORD"
      value = random_password.keycloak_master.result
    },
    {
      name  = "KC_DB_URL"
      value = "jdbc:postgresql://${module.keycloak_db.db_instance_address}:${module.keycloak_db.db_instance_port}/${module.keycloak_db.db_instance_name}"
    },
    {
      name  = "KC_DB"
      value = "postgres"
    },
    {
      name  = "KC_DB_USERNAME"
      value = module.keycloak_db.db_instance_username
    },
    {
      name  = "KC_HEALTH_ENABLED"
      value = "true"
    },
    {
      name  = "KC_HTTP_ENABLED"
      value = "true"
    },
    {
      name  = "KC_METRICS_ENABLED"
      value = "true"
    },
    {
      name  = "KEYCLOAK_ADMIN"
      value = "admin"
    },
    {
      name  = "KEYCLOAK_ADMIN_PASSWORD"
      value = random_password.keycloak_admin.result
    },
    {
      name  = "KC_FEATURES"
      value = "token-exchange"
    },
    {
      name  = "KC_HOSTNAME_URL",
      value = "https://auth.onfhir.cl"
    },
    {
      name  = "KC_HOSTNAME_ADMIN_URL",
      value = "https://auth.onfhir.cl"
    }
  ]
  command = ["start-dev"]
  memory  = "2048"
  cpu     = "512"

  log_group_name = "/ecs/${var.project}-${var.environment}/keycloak"

  tags = var.tags
}

################################################################################
# ECS Service Module
################################################################################

module "keycloak_ecs_service" {
  source = "./modules/ecs_modules/ecs_service"

  //cluster
  cluster_id = module.ecs_cluster.cluster_id
  vpc_id     = var.vpc_id

  //service
  task_definition_arn = module.keycloak_task_definition.task_definition_arn
  name                = local.keycloak
  subnet_ids          = var.private_subnet_ids

  //load balancer
  load_balancer = {
    internal   = false
    name       = local.keycloak
    subnet_ids = var.public_subnet_ids
    type       = "application"

    target_group = {
      name = local.keycloak
      port = 8080
      health_check = {
        path = "/health"
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
        certificate_arn = data.aws_acm_certificate.keycloak.arn
      }
    }
  }
  tags = var.tags
}

################################################################################
# Cloudwatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "keycloak_logs" {
  name              = "/ecs/${var.project}-${var.environment}/keycloak"
  retention_in_days = 7
  tags              = var.tags
}

