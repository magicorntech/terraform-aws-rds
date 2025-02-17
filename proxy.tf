resource "aws_db_proxy" "main" {
  count                  = var.deploy_rds_proxy ? 1 : 0
  name                   = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-${var.environment}"
  engine_family          = (var.engine == "postgres") ? "POSTGRESQL" : "MYSQL"
  role_arn               = aws_iam_role.rds_proxy_role[0].arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.main.id]
  require_tls            = true

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.rds_proxy_secret[0].arn
    iam_auth    = "DISABLED"
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_db_proxy_endpoint" "main_ro" {
  count                  = var.deploy_rds_proxy ? 1 : 0
  db_proxy_name          = aws_db_proxy.main[0].name
  db_proxy_endpoint_name = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-ro-${var.environment}"
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.main.id]
  target_role            = "READ_ONLY"

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-ro-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  count         = (var.deploy_rds_proxy == true) ? 1 : 0
  db_proxy_name = aws_db_proxy.main[0].name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "main" {
  count                  = (var.deploy_rds_proxy == true) ? 1 : 0
  db_instance_identifier = (var.aurora_cluster == true) ? null : aws_db_instance.main[0].identifier
  db_cluster_identifier  = (var.aurora_cluster == true) ? aws_rds_cluster.main[0].id : null
  db_proxy_name          = aws_db_proxy.main[0].name
  target_group_name      = aws_db_proxy_default_target_group.main[0].name
}

resource "aws_iam_role" "rds_proxy_role" {
  count = var.deploy_rds_proxy ? 1 : 0
  name  = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-role-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_iam_role_policy" "rds_proxy_policy" {
  count = var.deploy_rds_proxy ? 1 : 0
  name  = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-policy-${var.environment}"
  role  = aws_iam_role.rds_proxy_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [aws_secretsmanager_secret.rds_proxy_secret[0].arn]
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "rds_proxy_secret" {
  count = var.deploy_rds_proxy ? 1 : 0
  name  = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-secret-${var.environment}"

  tags = {
    Name        = "${var.tenant}-${var.name}-rds-${var.database_name}-proxy-secret-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_secretsmanager_secret_version" "rds_proxy_secret_version" {
  count     = var.deploy_rds_proxy ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_proxy_secret[0].id

  secret_string = jsonencode({
    username = (var.aurora_cluster == true) ? aws_rds_cluster.main[0].master_username : aws_db_instance.main[0].username
    password = random_password.dbpass.result
  })
}
