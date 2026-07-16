
# Add subnet group for rds
resource "aws_db_subnet_group" "private" {
  name       = "${local.project_name}-rds-private-sg"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "RDS Private Subnet Group"
  }
}

resource "aws_security_group" "rds_private" {
  name        = "${local.project_name}-sg"
  description = "Allow postgress access from eks"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-sg"
  }
}

# set ingress rule
resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds_private.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

resource "aws_db_instance" "main" {
  identifier     = "${local.project_name}-db"
  engine         = "postgres"
  engine_version = "18.4"
  instance_class = "db.t4g.micro"

  allocated_storage     = 10
  max_allocated_storage = 20
  storage_encrypted     = true

  db_name = "voting_app_eks"

  manage_master_user_password = true
  username                    = "postgres"

  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.rds_private.id]

  skip_final_snapshot = true

  tags = {
    Name = "${local.project_name}-rds"
  }
}
