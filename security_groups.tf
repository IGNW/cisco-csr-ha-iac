module "security_group_outside" {
  source  = "./modules/terraform-aws-security-group"

  name        = "csroutside"
  description = "Security group for public interface of csr1000v"
  vpc_id      = "${aws_vpc.private.id}"

  ingress_cidr_blocks = "${var.public_security_group_ingress_cidr_blocks}"
  ingress_rules       = "${var.public_security_group_ingress_rules}"
  egress_rules        = "${var.public_security_group_egress_rules}"
}

module "ssh_security_group" {
  source              = "./modules/terraform-aws-security-group/modules/ssh"
  name                = "csrssh"
  vpc_id              = "${aws_vpc.private.id}"
  ingress_cidr_blocks = "${var.ssh_ingress_cidr_block}"
}

module "security_group_inside" {
  source              = "./modules/terraform-aws-security-group"
  name                = "csrinside"
  description         = "Security group for private interface of csr1000v"
  vpc_id              = "${aws_vpc.private.id}"
  ingress_cidr_blocks = ["${aws_vpc.private.cidr_block}"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]
}

module "security_group_failover" {
  source  = "./modules/terraform-aws-security-group"

  name        = "csrfailover"
  description = "Security group for private interface of csr1000v"
  vpc_id      = "${aws_vpc.private.id}"

  ingress_cidr_blocks = ["${aws_vpc.private.cidr_block}"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${aws_vpc.private.cidr_block}"
    },
    {
      from_port   = 4790
      to_port     = 4790
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${aws_vpc.private.cidr_block}"
    },
  ]
  egress_rules = ["all-all"]
}
