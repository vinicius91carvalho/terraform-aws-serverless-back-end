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
- TODO Especificar os atributos necessários para que o usuário se cadastre
Talvez seja necessário uma tela a mais para obter essas informações do usuário e
criar uma tabela para guardar essas informações adicionais.
- Há a possibilidade de se disparar uma trigger com alguns eventos do Cognito.
 */
