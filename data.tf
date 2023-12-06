data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  engine = (
    (var.engine == "postgres") ? "aurora-postgresql" : false ||
    (var.engine == "mysql") ? "aurora-mysql" : null
  )
}

resource "random_string" "dbname" {
  length  = 10
  numeric = false
  special = false
}

resource "random_string" "dbuser" {
  length  = 12
  numeric = false
  special = false
}

resource "random_password" "dbpass" {
  length           = 16
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 2
  min_special      = 2
  override_special = "!#$%&*()-_=+[]{}<>:?"
}