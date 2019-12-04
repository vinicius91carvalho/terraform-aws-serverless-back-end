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

/*
  Cria um item na tabela anteior para testes integrados
*/
resource "aws_dynamodb_table_item" "simple_table_item" {
  table_name = "${aws_dynamodb_table.simple_table.name}"
  hash_key   = "${aws_dynamodb_table.simple_table.hash_key}"

  item = <<ITEM
{
  "id": {
    "S": "1"
  },
  "name": {
    "S": "A"
  }
}
ITEM
}

# Exporta o nome da tabela criada para o SSM
resource "aws_ssm_parameter" "dynamodb_hello_table" {
  name  = "${var.environment}-dynamodb-hello-table"
  type  = "String"
  value = aws_dynamodb_table.simple_table.name
}
