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
      variable = "token.actions.githubusercontent.com:sub"
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

resource "aws_iam_role" "voting_app_eks_deployment_role" {
  name               = "VotingAppEKSDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}
