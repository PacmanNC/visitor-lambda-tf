locals {
  json_data = file("./data.json")
  dynamodb_data = jsondecode(local.json_data)
}