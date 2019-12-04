resource "aws_iam_role" "group_role" {
  name = "cognito-user-group-role"

  assume_role_policy = templatefile("${path.module}/templates/cognito-user-group-policy.tpl", {})
}
