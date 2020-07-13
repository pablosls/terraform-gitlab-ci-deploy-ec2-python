# dynamo.tf
resource "aws_dynamodb_table" "tf_state_lock" {
  name           = "tf-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
attribute {
            name = "LockID"
            type = "S"
  }
}