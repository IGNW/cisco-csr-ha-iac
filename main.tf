data "aws_vpc" "default" {
  default = true
}

resource "aws_network_interface" "csr1000v1failover" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_failover.this_security_group_id.csrfailover}"]
}

resource "aws_network_interface" "csr1000v2failover" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_failover.this_security_group_id.csrfailover}"]
}

resource "aws_network_interface" "csr1000v1inside" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_inside.this_security_group_id.csrinside}"]
}

resource "aws_network_interface" "csr1000v2inside" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_inside.this_security_group_id.csrinside}"]
}

resource "aws_network_interface" "csr1000v1outside" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_outside.this_security_group_id.csroutside}"]
}

resource "aws_network_interface" "csr1000v2outside" {
  subnet_id = data.aws_vpc.default.id
  security_groups = ["${module.security_group_outside.this_security_group_id.csroutside}"]
}

module "security_group_outside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csroutside"
  description = "Security group for public interface of csr1000v"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "security_group_inside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrinside"
  description = "Security group for private interface of csr1000v"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]
}

module "security_group_failover" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrfailover"
  description = "Security group for private interface of csr1000v"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${data.aws_vpc.default.cidr_block}"
    },
    {
      from_port   = 4790
      to_port     = 4790
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${data.aws_vpc.default.cidr_block}"
    },
  ]
  egress_rules        = ["all-all"]
}

module instance1 {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  ami = "cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4" 
  associate_public_ip_address = false
  instance_type          = "t2.micro"
  name = "csr1000v1"
  key_name = "csr1000v"
  vpc_security_group_ids = []

  network_interface = [
    # Outside network Interface
    {
      device_index = 0
      network_interface_id  = aws_network_interface.csr1000v1outside.id
    },

    # Inside network Interface
    {
      device_index = 1
      network_interface_id  = aws_network_interface.csr1000v1inside.id
    },

    # Failover network Interface
    {
      device_index = 2
      network_interface_id  = aws_network_interface.csr1000v1failover.id
    },
  ]
  
}

module instance2 {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  ami = "cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4" 
  associate_public_ip_address = false
  name = "csr1000v2"
  key_name = "csr1000v"
  instance_type          = "t2.micro"
  vpc_security_group_ids = []
  network_interface = [
    # Outside network Interface
    {
      device_index = 0
      network_interface_id  = aws_network_interface.csr1000v2outside.id
    },

    # Inside network Interface
    {
      device_index = 1
      network_interface_id  = aws_network_interface.csr1000v2inside.id
    },

    # Failover network Interface
    {
      device_index = 2
      network_interface_id  = aws_network_interface.csr1000v2failover.id
    },
  ]
}
