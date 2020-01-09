resource "aws_key_pair" "csrkey" {
  key_name    = "cisco_router_ssh_key"
  public_key = base64decode("${var.base64encoded_public_ssh_key}")
}
