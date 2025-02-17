resource "aws_ssm_parameter" "main_db_host" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/host"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = (var.aurora_cluster == true) ? aws_rds_cluster.main[0].endpoint : aws_db_instance.main[0].address

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-host"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_port" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/port"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = var.port

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-port"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_name" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/name"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = (var.aurora_cluster == true) ? aws_rds_cluster.main[0].database_name : aws_db_instance.main[0].db_name

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-name"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_user" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/user"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = (var.aurora_cluster == true) ? aws_rds_cluster.main[0].master_username : aws_db_instance.main[0].username

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-user"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_pass" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/pass"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = random_password.dbpass.result

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-pass"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_proxy" {
  count       = (var.deploy_rds_proxy == true) ? 1 : 0
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/proxy"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = aws_db_proxy.main[0].endpoint

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-proxy"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_ssm_parameter" "main_db_proxy_ro" {
  count       = (var.deploy_rds_proxy == true) ? 1 : 0
  name        = "/${var.tenant}/${var.name}/${var.environment}/rds/${var.database_name}/proxy-ro"
  description = "Managed by Magicorn"
  type        = "SecureString"
  value       = aws_db_proxy_endpoint.main_ro[0].endpoint

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-rds-${var.database_name}-proxy-ro"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}