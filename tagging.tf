locals {
  # Common tags to be assigned to all resources
  common_tags = {
    name        = "vpc-east to vpc-west VPC peering"
    client      = "cisco"
    project     = "CSR HA"
    owner       = "tomc@ignw.io"
  }
}