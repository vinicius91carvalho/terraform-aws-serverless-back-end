/*
  Cria a role com a política base para autorizar a Lambda a assumir este papel
*/
resource "aws_iam_role" "hello_dynamo_iam_role" {
  name = "${var.environment}-hello-dynamo-iam-role"

  assume_role_policy = templatefile("${path.module}/templates/lambda-base-policy.tpl", {})
}

/*
  Insere a role criada no SSM  (Amazon System Manager) para que o Serverless Framework possa consultar posteriormente
*/
resource "aws_ssm_parameter" "hello_dynamo_iam_role" {
  name  = "${var.environment}-hello-dynamo-iam-role"
  type  = "String"
  value = aws_iam_role.hello_dynamo_iam_role.arn
}

/*
  Cria a política de autorização de leitura na tabela
*/
resource "aws_iam_policy" "hello_dynamo_policy" {
  name = "${var.environment}-hello-dynamo-policy"

  policy = templatefile("${path.module}/templates/dynamodb-policy.tpl", {
    action   = "dynamodb:GetItem",
    resource = aws_dynamodb_table.simple_table.arn
  })
}

/*
  Associa a política criada ao papel
*/
resource "aws_iam_policy_attachment" "hello_dynamo_policy_attachment" {
  name       = "${var.environment}-hello-dynamo-attachment"
  roles      = ["${aws_iam_role.hello_dynamo_iam_role.name}"]
  policy_arn = aws_iam_policy.hello_dynamo_policy.arn
}
