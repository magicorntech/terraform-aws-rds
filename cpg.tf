resource "aws_rds_cluster_parameter_group" "main" {
  count       = (var.aurora_cluster == true) ? 1 : 0
  name        = "${var.tenant}-${var.name}-rds-${var.database_name}-cpg-${var.environment}"
  description = "Managed by Magicorn"
  family      = (var.aurora_cluster == true) ? var.aurora_parameter_group : var.parameter_group

  dynamic "parameter" {
    for_each = (var.aurora_cluster == true && var.engine == "postgres") ? [true] : []
    content {
      name  = "rds.force_ssl"
      value = "1"
    }
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-cpg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}