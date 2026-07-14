# create ecr repositories
resource "aws_ecr_repository" "vote-repository" {
  name                 = "voting-app/vote"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "worker-repository" {
  name                 = "voting-app/worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "result-repository" {
  name                 = "voting-app/result"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
