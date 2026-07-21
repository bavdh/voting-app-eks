resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.main.name
  version         = local.eks_version
  node_group_name = "general"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = aws_subnet.private[*].id

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policies
  ]
}
