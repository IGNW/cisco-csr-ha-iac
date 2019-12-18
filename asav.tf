resource "aws_instance" "training_asav" {
  ami = "ami-9144c2e9"
  instance_type = "c4.large"
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-private.*.id, count.index)}"
  vpc_security_group_ids = ["${element(aws_security_group.student_router.*.id, count.index)}"]
  key_name = "student"
  private_ip = "10.1.2.102"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - ASAv - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }
}
