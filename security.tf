resource "aws_security_group" "student_node" {
  name = "student_node"
  description = "Allows all inbound traffic for now"
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  tags = {
    Project = "${var.project}"
    Name = "${var.project} - Public Security Group - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "student_router" {
  name = "student_router"
  description = "Allows all traffic from internal VPC"
  count = "${length(var.students)}"
  vpc_id = "${element(aws_vpc.training.*.id, count.index)}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.1.0/24"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.1.0/24"]
  }

  tags = {
    Project = "${var.project}"
    Name = "${var.project} - Private Security Group - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}
