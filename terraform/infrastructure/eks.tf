resource "aws_eks_cluster" "main" {
  name = local.eks_cluster_name

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = local.eks_version

  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }

  access_config {
    authentication_mode = "API"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_pod_identity_association" "eso" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.eso_role.arn
}

data "aws_iam_role" "kubernetes_deploy_role" {
  name = "VotingAppEKSKubernetesDeploymentRole"
}

resource "aws_eks_access_entry" "kubernetes_deploy" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = data.aws_iam_role.kubernetes_deploy_role.arn
  kubernetes_groups = ["k8s-deploy-group"]
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::${var.aws_account}:user/bav-admin-user"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::${var.aws_account}:user/bav-admin-user"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller.arn
}
