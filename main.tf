module "ecs_cluster" {
  source = "./modules/ecs_modules/ecs_cluster"

  cluster_name = "${var.project}-${var.environment}"

  tags = merge(
    {
      "Name" = "${var.project}-${var.environment}"
    },
    var.tags
  )
}

################################################################################
# Subnet Group from Module
################################################################################
module "subnet_group" {
  source      = "./modules/rds_modules/rds_db_subnet_group"
  name        = "${var.project}-${var.environment}-db-subnet-group"
  name_prefix = false
  subnet_ids  = var.private_subnet_ids
  description = "DB subnet group for ${var.project}-${var.environment}"

  tags = merge(
    {
      "Name" = "${var.project}-${var.environment}-db-subnet-group"
    },
    var.tags
  )
}

resource "aws_security_group" "allow_db_ports" {
  name        = "${var.project}-${var.environment}-allow-postgres"
  description = "Allow Postgres traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
  security_group_id = aws_security_group.allow_db_ports.id
  cidr_ipv4         = "172.16.0.0/16"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.allow_db_ports.id
  cidr_ipv4         = "172.16.0.0/16"
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_db_ports.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

