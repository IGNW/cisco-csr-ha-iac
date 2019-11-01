module "vpc-west_local" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name = "terraform-vpc-west_local"

  cidr = "10.0.0.0/16"

  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-east_local" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name = "terraform-vpc-east_local"

  cidr = "10.1.0.0/16"

  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = ["10.1.0.0/24", "10.1.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_vpc_peering_connection" "pc" {
  peer_vpc_id = module.vpc-west_local.vpc_id
  vpc_id      = module.vpc-east_local.vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "vpc-east_local to vpc-west_local VPC peering"
  }
}

resource "aws_route" "vpc-peering-route-east" {
  count                     = 2
  route_table_id            = module.vpc-east_local.public_route_table_ids[0]
  destination_cidr_block    = module.vpc-west_local.public_subnets_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
}

resource "aws_route" "vpc-peering-route-west" {
  count                     = 2
  route_table_id            = module.vpc-west.public_route_table_ids[0]
  destination_cidr_block    = module.vpc-east.public_subnets_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
}
