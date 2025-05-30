resource "aws_dynamodb_table" "results_table" {
  name           = "CompatibilityResults-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
}