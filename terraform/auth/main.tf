// Configura um novo pool de usuários
resource "aws_cognito_user_pool" "pool" {
  name                     = "${var.environment}-${var.pool_name}"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

// Configura um novo cliente para conexão ao Cognito
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.environment}-${var.pool_name}-client"

  user_pool_id        = aws_cognito_user_pool.pool.id
  generate_secret     = false
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
}

/*
  Insere a role criada no SSM  (Amazon System Manager) para que o Serverless Framework possa consultar posteriormente
*/
resource "aws_ssm_parameter" "cognito-user-pool-arn" {
  name  = "${var.environment}-cognito-user-pool-arn"
  type  = "String"
  value = aws_cognito_user_pool.pool.arn
}


/*
  Cria o grupo de usuário
*/
resource "aws_cognito_user_group" "user_group" {
  name         = var.group_name
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Managed by Terraform"
  role_arn     = aws_iam_role.cognito_group_role.arn
}

/*
  Cria um novo usuário no Cognito
*/
resource "null_resource" "create_cognito_user" {

  provisioner "local-exec" {
    command = "aws cognito-idp sign-up --client-id ${aws_cognito_user_pool_client.client.id} --username ${var.user_email} --password ${var.user_password}"
  }

  depends_on = [aws_cognito_user_group.user_group]
}

/*
  Confirma o cadastro do usuário
*/
resource "null_resource" "confirm_sign_up" {

  provisioner "local-exec" {
    command = "aws cognito-idp admin-confirm-sign-up --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.user_email}"
  }

  depends_on = [null_resource.create_cognito_user]
}

/*
  Adiciona o usuário no grupo
*/
resource "null_resource" "add_user_to_group" {

  provisioner "local-exec" {
    command = "aws cognito-idp admin-add-user-to-group --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.user_email} --group-name ${aws_cognito_user_group.user_group.name}"
  }

  depends_on = [null_resource.confirm_sign_up]
}
