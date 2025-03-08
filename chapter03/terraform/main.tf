resource "aws_sqs_queue" "my_queue" {
  name             = "test-queue-tf"
  max_message_size = 4096
  tags = {
    Name = "test-queue-tf"
  }
}
