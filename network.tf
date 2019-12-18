resource "aws_vpc" "training" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  count = "${length(var.students)}"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - VPC - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}

resource "aws_internet_gateway" "training" {
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - Gateway - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}

resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    count = "${length(var.students)}"
    vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags {
    Project = "${var.project}"
    Name = "${var.project} - NAT Security Group - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}

resource "aws_instance" "nat" {
  ami = "ami-35d6664d"
  availability_zone = "us-west-2b"
  instance_type = "m1.small"
  vpc_security_group_ids = ["${element(aws_security_group.nat.*.id, count.index)}"]
  associate_public_ip_address = true
  source_dest_check = false
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-public.*.id, count.index)}"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - NAT Node - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

}

# PUBLIC SUBNET

resource "aws_subnet" "us-west-2b-public" {
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"
  cidr_block = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2b"
  tags {
    Project = "${var.project}"
    Name = "${var.project} - Public Subnet - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}

resource "aws_route_table" "us-west-2b-public" {
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.training.*.id, count.index)}"
  }

  tags {
    Project = "${var.project}"
    Name = "${var.project} - Public Route Table - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

}

resource "aws_route_table_association" "us-west-2b-public" {
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.us-west-2b-public.*.id, count.index)}"

}

# PRIVATE SUBNET

resource "aws_subnet" "us-west-2b-private" {
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-west-2b"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - Private Subnet - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}

resource "aws_route_table" "us-west-2b-private" {
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${element(aws_instance.nat.*.id, count.index)}"
  }

  tags {
    Project = "${var.project}"
    Name = "${var.project} - Private Subnet Route Table - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

}

resource "aws_route_table_association" "public_subnet" {
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.us-west-2b-private.*.id, count.index)}"
}
