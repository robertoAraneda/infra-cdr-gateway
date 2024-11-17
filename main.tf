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