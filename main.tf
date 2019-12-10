resource "aws_vpc" "csr1000vvpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "csr1000vvpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.csr1000vvpc.id}"
}

resource "aws_subnet" "sub1" {
  vpc_id            = "${aws_vpc.csr1000vvpc.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "${cidrsubnet(aws_vpc.csr1000vvpc.cidr_block, 4, 1)}"
}

resource "aws_network_interface" "csr1000v1failover" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_failover.this_security_group_id}"]
  attachment {
    instance     = "${module.instance1.id}"
    device_index = 1
  }
}

resource "aws_network_interface" "csr1000v2failover" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_failover.this_security_group_id}"]
}

resource "aws_network_interface" "csr1000v1inside" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_inside.this_security_group_id}"]

}

resource "aws_network_interface" "csr1000v2inside" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_inside.this_security_group_id}"]
}

resource "aws_network_interface" "csr1000v1outside" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_outside.this_security_group_id}"]
}

resource "aws_network_interface" "csr1000v2outside" {
  subnet_id = aws_subnet.sub1.id
  security_groups = ["${module.security_group_outside.this_security_group_id}"]
}

module "security_group_outside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csroutside"
  description = "Security group for public interface of csr1000v"
  vpc_id      = aws_vpc.csr1000vvpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "security_group_inside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrinside"
  description = "Security group for private interface of csr1000v"
  vpc_id      = aws_vpc.csr1000vvpc.id

  ingress_cidr_blocks = ["${aws_vpc.csr1000vvpc.cidr_block}"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]
}

module "security_group_failover" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrfailover"
  description = "Security group for private interface of csr1000v"
  vpc_id      = aws_vpc.csr1000vvpc.id

  ingress_cidr_blocks = ["${aws_vpc.csr1000vvpc.cidr_block}"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${aws_vpc.csr1000vvpc.cidr_block}"
    },
    {
      from_port   = 4790
      to_port     = 4790
      protocol    = "udp"
      description = "Failover udp check between routers"
      cidr_blocks = "${aws_vpc.csr1000vvpc.cidr_block}"
    },
  ]
  egress_rules        = ["all-all"]
}

module instance1 {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  #ami = "cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4" 
  #ami = "ami-0fc7a3d5400f4619d"
  ami = "${data.aws_ami.csr1000v.id}"
  instance_type          = "c4.large"
  subnet_id = aws_subnet.sub1.id
  name = "csr1000v1"
  key_name = "csr1000v"
  associate_public_ip_address = true
  #network_interface = [
  #  # Outside network Interface
  #  {
  #    device_index = 0
  #    network_interface_id  = aws_network_interface.csr1000v1outside.id
  #  },

  #  # Inside network Interface
  #  {
  #    device_index = 1
  #    network_interface_id  = aws_network_interface.csr1000v1inside.id
  #  },

  #  # Failover network Interface
  #  {
  #    device_index = 2
  #    network_interface_id  = aws_network_interface.csr1000v1failover.id
  #  },
  #]
  
}

data "aws_ami" "csr1000v" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Cisco

}

module instance2 {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  associate_public_ip_address = true
  ami = "${data.aws_ami.csr1000v.id}"
  name = "csr1000v2"
  key_name = "csr1000v"
  instance_type          = "c4.large"
  subnet_id = aws_subnet.sub1.id
  #network_interface = [
  #  # Outside network Interface
  #  {
  #    device_index = 0
  #    network_interface_id  = aws_network_interface.csr1000v2outside.id
  #  },

  #  # Inside network Interface
  #  {
  #    device_index = 1
  #    network_interface_id  = aws_network_interface.csr1000v2inside.id
  #  },

  #  # Failover network Interface
  #  {
  #    device_index = 2
  #    network_interface_id  = aws_network_interface.csr1000v2failover.id
  #  },
  #]
}
