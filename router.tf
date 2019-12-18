resource "aws_instance" "training_router" {
  ami = "ami-b1cd75c9"
  instance_type = "t2.medium"
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-private.*.id, count.index)}"
  vpc_security_group_ids = ["${element(aws_security_group.student_router.*.id, count.index)}"]
  key_name = "student"
  private_ip = "10.1.2.101"

  tags = {
    Project = "${var.project}"
    Name = "${var.project} - Router - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}
