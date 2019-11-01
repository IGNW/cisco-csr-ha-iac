output "vpc-west" {
  value = module.vpc-west_local.vpc_id
}

output "vpc-east" {
  value = module.vpc-east_local.vpc_id
}

output "vpc_peering_connection" {
  value = aws_vpc_peering_connection.pc.id
}
