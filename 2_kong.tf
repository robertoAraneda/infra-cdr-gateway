locals {
  kong = "${var.project}-${var.environment}-kong"
}

#########################
# Create Unique password
#########################

resource "random_password" "kong_master" {
  length           = 16
  special          = false
  override_special = "_!%^"
}


################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "kong" {
  domain_name       = "gateway.onfhir.cl"
  validation_method = "DNS"
  tags = merge(
    {
      "Name" = "gateway.onfhir.cl"
    },
    var.tags
  )
}


// DB Parameter group
resource "aws_db_parameter_group" "kong" {
  name   = "rds-kong"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# RDS DB Instance Module
################################################################################
module "kong_db" {
  source = "./modules/rds_modules/rds_db_instance"

  identifier = "${var.project}-${var.environment}-kong-db"

  engine         = "postgres"
  engine_version = "15.7"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 1000

  db_name  = "kong"
  username = "kong"
  port     = 5432
  password = random_password.kong_master.result

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


module "kong_task_definition" {
  source = "./modules/ecs_modules/ecs_task_definition"

  family          = local.kong
  container_name  = local.kong
  container_image = "robertoaraneda/kong-with-plugins:1.1.0"
  container_ports = [8000, 8443, 8001, 8002, 8444, 8100]
  environment = [
    {
      name  = "KONG_PG_HOST"
      value = module.kong_db.db_instance_address
    },
    {
      name  = "KONG_PG_PASSWORD"
      value = random_password.kong_master.result
    },
    {
      name  = "KONG_PROXY_LISTEN"
      value = "0.0.0.0:8000"
    },
    {
      name  = "KONG_PROXY_LISTEN_SSL"
      value = "0.0.0.0:8443"
    },
    {
      name  = "KONG_ADMIN_LISTEN"
      value = "0.0.0.0:8001"
    },
    {
      name  = "KONG_STATUS_LISTEN"
      value = "0.0.0.0:8100"
    },
    {
      name  = "KONG_PLUGINS"
      value = "bundled, token-introspection"
    },
    {
      name  = "KONG_PROXY_ACCESS_LOG"
      value = "/dev/stdout"
    },
    {
      name  = "KONG_ADMIN_ACCESS_LOG"
      value = "/dev/stdout"
    },
    {
      name  = "KONG_PROXY_ERROR_LOG"
      value = "/dev/stderr"
    },
    {
      name  = "KONG_ADMIN_ERROR_LOG"
      value = "/dev/stderr"
    },
    {
      name  = "KONG_LOG_LEVEL"
      value = "debug"
    }
  ]
  memory = "2048"
  cpu    = "512"

  log_group_name = "/ecs/${var.project}-${var.environment}/kong"

  tags = var.tags

}

// create ingress rule for kong port 8100
resource "aws_vpc_security_group_ingress_rule" "kong_status_ingress" {
  security_group_id = module.kong_ecs_service.aws_security_group_ecs_service_id

  from_port                    = 8100
  ip_protocol                  = "tcp"
  to_port                      = 8100
  referenced_security_group_id = module.kong_ecs_service.aws_security_group_load_balancer_id
}

module "kong_ecs_service" {
  source = "./modules/ecs_modules/ecs_service_v2"

  //cluster
  cluster_id = module.ecs_cluster.cluster_id
  vpc_id     = var.vpc_id

  //service
  task_definition_arn = module.kong_task_definition.task_definition_arn
  name                = local.kong
  subnet_ids          = var.private_subnet_ids

  //load balancer for 8000 port
  load_balancers = [
    {
      internal   = false
      name       = local.kong
      subnet_ids = var.public_subnet_ids
      type       = "application"

      target_group = {
        name = local.kong
        port = 8000
        health_check = {
          path = "/status"
          port = 8100
        }
      }
      listeners = {
        http = {
          enabled     = true
          action_type = "forward"
        }
        https = {
          enabled = false
          #action_type     = "forward"
          #certificate_arn = data.aws_acm_certificate.kong.arn
        }
      }
    },
    {
      internal   = false
      name       = "${local.kong}-admin"
      subnet_ids = var.public_subnet_ids
      type       = "application"

      target_group = {
        name = "${local.kong}-admin"
        port = 8001
        health_check = {
          path = "/status"
          port = 8100
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
  ]
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "kong_logs" {
  name              = "/ecs/${var.project}-${var.environment}/kong"
  retention_in_days = 7
  tags              = var.tags
}
