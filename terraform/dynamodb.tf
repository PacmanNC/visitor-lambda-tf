resource "aws_dynamodb_table" "visitor2-dynamodb" {
  name           = var.db_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "visitor_id"

  attribute {
    name = "visitor_id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "visitor2-init-items" {
  for_each   = local.dynamodb_data
  table_name = aws_dynamodb_table.visitor2-dynamodb.name
  hash_key       = "visitor_id"
  item       = jsonencode(each.value)

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      item
    ]
  }
}
