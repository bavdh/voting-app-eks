resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  version          = "2.7.0"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    aws_eks_node_group.general,
    aws_iam_role.eso_role,
  ]
}
