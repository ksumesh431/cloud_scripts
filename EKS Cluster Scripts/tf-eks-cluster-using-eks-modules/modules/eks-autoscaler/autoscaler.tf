# Creating the IAM Policy required for Cluster autoscaler
# Doc link: https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/
locals{
    cluster_name = var.cluster_name
}

data "aws_iam_policy_document" "policy_document" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeLaunchTemplateVersions",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "ec2:DescribeInstanceTypes",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "cluster-autoscaler-policy-${var.cluster_name}"  # Replace with a desired name for the policy
  description = "EKS Cluster autoscaler policy for ${var.cluster_name} cluster created with Terraform"
  policy      = data.aws_iam_policy_document.policy_document.json
}
