output "ecr_repository_urls" {
  value = {
    vote   = aws_ecr_repository.vote-repository.repository_url
    worker = aws_ecr_repository.worker-repository.repository_url
    result = aws_ecr_repository.result-repository.repository_url
  }
}
