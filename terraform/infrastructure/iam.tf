# EKS Cluster role
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "VotingAppEKSClusterRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Node role
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "VotingAppEKSNodeRole"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

# Attach managed policies to node role
resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

# add secrets permssion for eso secrets policy 
data "aws_iam_policy_document" "eso_secrets_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.main.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "eso_secrets_access" {
  name   = "${local.project_name}-eso-secrets-access"
  policy = data.aws_iam_policy_document.eso_secrets.access.json
}

# Add trust pod identity
data "aws_iam_policy_document" "eso_pod_identity_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eso_role" {
  name               = "${local.project_name}-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eso_pod_identity_trust.json
}

resource "aws_iam_role_policy_attachment" "eso_secrets_attach" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_secrets_access.arn
}
