# PUBLIC SUBNET
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.private.id}"
}

resource "aws_subnet" "public1" {
  vpc_id                  = "${aws_vpc.private.id}"
  availability_zone       = "us-west-2a"
  cidr_block              = "10.16.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "csrv1000vpublicsubnet1"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public2" {
  vpc_id                  = "${aws_vpc.private.id}"
  availability_zone       = "us-west-2a"
  cidr_block              = "10.16.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "csrv1000vpublicsubnet2"
  }
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.private.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "csrv1000vpublic"
  }

}

# PRIVATE SUBNET
resource "aws_vpc" "private" {
  cidr_block = "10.16.0.0/16"
}

resource "aws_subnet" "private1" {
  vpc_id            = "${aws_vpc.private.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.16.3.0/24"
  tags = {
    Name = "csrv1000vprivatesubnet1"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "private2" {
  vpc_id            = "${aws_vpc.private.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.16.4.0/24"
  tags = {
    Name = "csrv1000vprivatesubnet2"
  }
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.private.id
  tags = {
    Name = "csrv1000vprivate"
  }
}

resource "aws_network_interface" "csr1000v1eth1" {
  subnet_id         = aws_subnet.private1.id
  security_groups   = ["${module.security_group_inside.this_security_group_id}"]
  private_ips       = ["10.16.3.252"]
  source_dest_check = false
  attachment {
    instance     = join("", "${module.instance1.id}")
    device_index = 1
  }
}

resource "aws_network_interface" "csr1000v2eth1" {
  subnet_id         = aws_subnet.private2.id
  private_ips       = ["10.16.4.253"]
  security_groups   = ["${module.security_group_inside.this_security_group_id}"]
  source_dest_check = false
  attachment {
    instance     = join("", "${module.instance2.id}")
    device_index = 1
  }
}

resource "aws_iam_instance_profile" "csr1000v" {
  name = "csr1000v"
  role = "${aws_iam_role.csr_role.name}"
}

resource "aws_iam_policy" "csrpolicy" {
  name        = "csr_policy"
  path        = "/"
  description = "My test policy"

  policy = <<EOF
{
"Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "cloudwatch:",
                "s3:",
                "ec2:AssociateRouteTable",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DescribeRouteTables",
                "ec2:DescribeVpcs",
                "ec2:ReplaceRoute",
                "ec2:DescribeRegions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DisassociateRouteTable",
                "ec2:ReplaceRouteTableAssociation",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "csr_role" {
  name                 = "csr1000v"
  path                 = "/"
  permissions_boundary = aws_iam_policy.csrpolicy.arn

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

module "security_group_outside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csroutside"
  description = "Security group for public interface of csr1000v"
  vpc_id      = aws_vpc.private.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "ssh_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/ssh"
  version             = "~> 3.0"
  name                = "csrssh"
  vpc_id              = aws_vpc.private.id
  ingress_cidr_blocks = ["0.0.0.0/0", "66.68.99.194/32"]

}

module "security_group_inside" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrinside"
  description = "Security group for private interface of csr1000v"
  vpc_id      = aws_vpc.private.id

  ingress_cidr_blocks = ["${aws_vpc.private.cidr_block}"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]
}

module "security_group_failover" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "csrfailover"
  description = "Security group for private interface of csr1000v"
  vpc_id      = aws_vpc.private.id

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

module instance1 {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  ami                         = "${data.aws_ami.csr1000v.id}"
  instance_type               = "c4.large"
  subnet_id                   = aws_subnet.public1.id
  name                        = "csr1000v1"
  key_name                    = "csr"
  iam_instance_profile        = "${aws_iam_instance_profile.csr1000v.name}"
  associate_public_ip_address = true
  #private_ip = "10.16.1.2"
  vpc_security_group_ids = ["${module.security_group_outside.this_security_group_id}", "${module.ssh_security_group.this_security_group_id}"]
}

data "aws_ami" "csr1000v" {
  most_recent = true

  filter {
    name = "name"
    #values = ["cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4"]
    #values = ["cisco-CSR-.16.12.01a-SEC-HVM-dbfcb230-402e-49cc-857f-dacb4db08d34-ami-07e60a9fabe437907.4"] 
    values = ["cisco-CSR-.16.12.01a-AX-HVM-9f5a4516-a4c3-4cf1-89d4-105d2200230e-ami-0f6fdba70c4443b5f.4"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Cisco

}

module instance2 {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  associate_public_ip_address = true
  ami                         = "${data.aws_ami.csr1000v.id}"
  name                        = "csr1000v2"
  key_name                    = "csr"
  instance_type               = "c4.large"
  iam_instance_profile        = "${aws_iam_instance_profile.csr1000v.name}"
  subnet_id                   = aws_subnet.public2.id
  vpc_security_group_ids      = ["${module.security_group_outside.this_security_group_id}", "${module.ssh_security_group.this_security_group_id}"]
  #private_ip = "10.16.2.2"
}


resource "null_resource" "iface1" {
  # Changes to any instance of interfaces
  triggers = {
    interface_changes = aws_network_interface.csr1000v1eth1.id
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.ha_configure_script.rendered}' > tmpscript && chmod 700 tmpscript && ./tmpscript"
  }

}

locals {
  template_vars = {
    csrv1_public_ip    = module.instance1.public_ip[0]
    csrv2_public_ip    = module.instance2.public_ip[0]
    csrv1_eth1_private = "${aws_network_interface.csr1000v1eth1.private_ip}"
    csrv2_eth1_private = "${aws_network_interface.csr1000v2eth1.private_ip}"
    private_rtb        = "${aws_route_table.private.id}"
    csrv1_eth1_eni     = "${aws_network_interface.csr1000v1eth1.id}"
    csrv2_eth1_eni     = "${aws_network_interface.csr1000v2eth1.id}"
  }
}

data "template_file" "ha_configure_script" {
  template = "${file("${path.module}/init.sh.tpl")}"
  vars     = "${local.template_vars}"
}
