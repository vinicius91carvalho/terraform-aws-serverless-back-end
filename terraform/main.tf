/*
  Obtém informações da conta do usuário que executará as operações na Cloud
*/
data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

/*
  Configura o estado remoto deste projeto. 
  Basicamente cria bucket e a tabela no dynamodb para permitir apenas uma execução por vez da infra
  O estado é guardado no S3 e o Lock é feita na tabela
  Observação: Esses valores não podem ser dinâmicos e deve-se utilizar os Workspaces do Terraform
*/
terraform {
  backend "s3" {
    bucket         = "project-name-982687753950-us-east-1-remote-state"
    key            = "back-end/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-name-982687753950-us-east-1-remote-state"
  }
}

/*
  Módulo de Autenticação
*/
module "auth" {
  source        = "./auth"
  environment   = var.environment
  pool_name     = "project-name-user-pool"
  user_email    = var.user_cognito_email
  user_password = var.user_cognito_password
  group_name    = var.group_cognito_name
}


/*
  Módulo da API Hello Dynamo
*/
module "hello_dynamo" {
  source         = "./api/hello-dynamo"
  environment    = var.environment
  write_capacity = 1
  read_capacity  = 1
}
