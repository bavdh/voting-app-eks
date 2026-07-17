resource "aws_eks_cluster" "main" {
  name = local.eks_cluster_name

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = local.eks_version

  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-prod-identity-agent"
}
