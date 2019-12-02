/*
  Cria a tabela no DynamoDB
*/
resource "aws_dynamodb_table" "simple_table" {
  name     = "${var.environment}-simple-table"
  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
  write_capacity = var.write_capacity
  read_capacity  = var.read_capacity
}

# Exporta o nome da tabela criada para o SSM
resource "aws_ssm_parameter" "dynamodb_hello_table" {
  name  = "${var.environment}-dynamodb-hello-table"
  type  = "String"
  value = aws_dynamodb_table.simple_table.name
}
