resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.project_name}-cache-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_security_group" "redis" {
  name        = "${local.project_name}-redis-sg"
  description = "Allow Redis access from ECS tasks"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-redis-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  security_group_id            = aws_security_group.redis.id
  description                  = "Allow Redis from ECS instance SG"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id

  tags = {
    Name = "${local.project_name}-redis-ingress"
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id         = "${local.project_name}-redis"
  engine             = "redis"
  engine_version     = "7.1"
  node_type          = "cache.t4g.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  tags = {
    Name = "${local.project_name}-redis"
  }
}
