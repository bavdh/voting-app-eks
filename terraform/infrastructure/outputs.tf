output "ecr_repository_urls" {
  value = {
    vote   = aws_ecr_repository.vote-repository.repository_url
    worker = aws_ecr_repository.worker-repository.repository_url
    result = aws_ecr_repository.result-repository.repository_url
  }
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}
