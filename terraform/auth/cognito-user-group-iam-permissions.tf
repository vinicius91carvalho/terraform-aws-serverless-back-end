resource "aws_iam_role" "cognito_group_role" {
  name = "${var.environment}-cognito-user-group-role"

  assume_role_policy = templatefile("${path.module}/templates/cognito-user-group-policy.tpl", {})
}
