# Add github oidc identity provider
resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "iam_oidc_provider_github"
  }
}

# Add role and policy for github oidc
data "aws_iam_policy_document" "github_actions_oidc_trust_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:bavdh/voting-app-eks:ref:refs/heads/main"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_oidc_role" {
  name               = "GithubVotingAppEKSOIDCRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_policy.json
}

# Add deployment role
data "aws_iam_policy_document" "github_actions_oidc_trust_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_actions_oidc_role.arn]
    }
  }
}

resource "aws_iam_role" "eks_deployment_role" {
  name               = "VotingAppEKSDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}

# Add ecr deployment role
data "aws_iam_policy_document" "ecr_deployment_policy_document" {
  statement {
    sid    = "RepoManagement"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:ListTagsForResource",
      "ecr:PutImageTagMutability"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${var.aws_account}:repository/voting-app/*"]
  }
}

resource "aws_iam_role" "ecr_deployment_role" {
  name               = "VotingAppEksECRDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}

resource "aws_iam_role_policy" "ecr_deployment_role_inline_policy" {
  name   = "VotingAppEksECRDeploymentPolicy"
  role   = aws_iam_role.ecr_deployment_role.id
  policy = data.aws_iam_policy_document.ecr_deployment_policy_document.json
}

# Add kubernetes deployment role
resource "aws_iam_role" "kubernetes_deployment_role" {
  name               = "VotingAppEKSKubernetesDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}
