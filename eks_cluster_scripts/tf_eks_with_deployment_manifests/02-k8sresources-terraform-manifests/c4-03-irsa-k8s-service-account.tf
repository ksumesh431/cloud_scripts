# Resource: Kubernetes Service Account
resource "kubernetes_service_account_v1" "irsa_demo_sa" {
  depends_on = [ aws_iam_role_policy_attachment.irsa_iam_role_policy_attach ]
  metadata {
    name = "irsa-demo-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_iam_role.arn
      # The above aws_iam_role.irsa_iam_role.arn is definded in the output section of c4-02-irsa-iam-policy-and-role.tf file
      }
  }
}

