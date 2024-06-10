resource "random_id" "backup" {
  byte_length = 8
}

##################
##### RDS Instance
resource "aws_db_instance" "main" {
  count                       = (var.aurora_cluster == false) ? 1 : 0
  deletion_protection         = var.deletion_protection
  db_name                     = random_string.dbname.result
  engine                      = var.engine
  engine_version              = var.engine_version
  identifier                  = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}"
  instance_class              = var.instance_type
  username                    = random_string.dbuser.result
  password                    = random_password.dbpass.result
  parameter_group_name        = aws_db_parameter_group.main.id
  skip_final_snapshot         = false
  storage_encrypted           = (var.encryption == true) ? true : false
  kms_key_id                  = (var.encryption == true) ? var.kms_key_id : null
  storage_type                = var.storage_type
  storage_throughput          = var.storage_throughput
  multi_az                    = var.multi_az
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  final_snapshot_identifier   = "${var.tenant}-${var.name}-${var.database_name}-final-${random_id.backup.hex}-${var.environment}"
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  db_subnet_group_name        = aws_db_subnet_group.main.name
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.main.id]
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

########################
##### RDS Aurora Cluster
resource "aws_rds_cluster" "main" {
  count                           = (var.aurora_cluster == true) ? 1 : 0
  deletion_protection             = var.deletion_protection
  engine                          = local.engine
  engine_mode                     = "provisioned"
  engine_version                  = var.engine_version
  cluster_identifier              = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}"
  database_name                   = random_string.dbname.result
  master_username                 = random_string.dbuser.result
  master_password                 = random_password.dbpass.result
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  preferred_maintenance_window    = var.maintenance_window
  final_snapshot_identifier       = "${var.tenant}-${var.name}-${var.database_name}-final-${random_id.backup.hex}-${var.environment}"
  copy_tags_to_snapshot           = true
  storage_encrypted               = (var.encryption == true) ? true : false
  kms_key_id                      = (var.encryption == true) ? var.kms_key_id : null
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main[0].id
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.main.id]
  apply_immediately               = var.apply_immediately

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                      = local.node_count
  identifier                 = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}-${count.index + 1}"
  instance_class             = var.instance_type
  cluster_identifier         = aws_rds_cluster.main[0].id
  engine                     = aws_rds_cluster.main[0].engine
  engine_version             = aws_rds_cluster.main[0].engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  copy_tags_to_snapshot      = true
  db_parameter_group_name    = aws_db_parameter_group.main.id
  db_subnet_group_name       = aws_db_subnet_group.main.name
  publicly_accessible        = false
  apply_immediately          = var.apply_immediately

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.database_name}-${var.environment}-${count.index + 1}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}
