variable "availability_zone" {
  defalt = "us-west-2a"
}

variable "private_vpc_cidr_block" {
  default = "10.16.0.0/16"
}

variable "node1_private_cidr_block" {
  default = "10.16.3.0/24"
}

variable "node1_eth1_private_ip" {
  default = "10.16.3.252"
}

variable "node2_eth1_private_ip" {
  default = "10.16.4.253"
}

variable "node2_private_cidr_block" {
  default = "10.16.4.0/24"
}

variable "node1_public_cidr_block" {
  default = "10.16.1.0/24"
}

variable "node2_public_cidr_block" {
  default = "10.16.2.0/24"
}

variable "public_route_table_allowed_cidr" {
  default = "0.0.0.0/0"
}

variable "public_security_group_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "public_security_group_egress_rules" {
  default = ["all-all"]
}

variable "ssh_ingress_cidr_block" {
  default = ["0.0.0.0/0"]
}

variable "public_security_group_ingress_rules" {
  default = ["https-443-tcp", "http-80-tcp", "all-icmp"]
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "aws_region" {
  default = "us-east-1"
}
