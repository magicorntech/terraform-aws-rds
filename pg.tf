resource "aws_db_parameter_group" "main" {
  name        = "${var.tenant}-${var.name}-rds-${var.database_name}-pg-${var.environment}"
  description = "Managed by Magicorn"
  family      = (var.aurora_cluster == true) ? var.aurora_parameter_group : var.parameter_group

  dynamic "parameter" {
    for_each = (var.aurora_cluster == false && var.engine == "postgres") ? [true] : []

    content {
      name  = "rds.force_ssl"
      value = "1"
    }
  }

  dynamic "parameter" {
    for_each = var.parameter

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-pg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}
