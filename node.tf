resource "aws_instance" "training_node" {
  ami = "ami-14348d6c"
  instance_type = "m3.medium"
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-private.*.id, count.index)}"
  key_name = "student"
  vpc_security_group_ids = ["${element(aws_security_group.student_router.*.id, count.index)}"]
  private_ip = "10.1.2.100"

  tags {
    Project = "${var.project}"
    Name = "${var.project} - Node - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

  provisioner "file" {
    content = "${var.private_key}"
    destination = "/home/ubuntu/.ssh/id_rsa"
    connection {
      type         = "ssh"
      user         = "ubuntu"
      private_key  = "${var.private_key}"
      bastion_host = "${element(aws_instance.desktop.*.public_ip, count.index)}"
      bastion_user = "ubuntu"
      bastion_private_key = "${var.private_key}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/ubuntu/.ssh/id_rsa"
    ]
    connection {
      type         = "ssh"
      user         = "ubuntu"
      private_key  = "${var.private_key}"
      bastion_host = "${element(aws_instance.desktop.*.public_ip, count.index)}"
      bastion_user = "ubuntu"
      bastion_private_key = "${var.private_key}"
    }
  }

  provisioner "file" {
    content = "${var.public_key}"
    destination = "/home/ubuntu/.ssh/id_rsa.pub"
    connection {
      type         = "ssh"
      user         = "ubuntu"
      private_key  = "${var.private_key}"
      bastion_host = "${element(aws_instance.desktop.*.public_ip, count.index)}"
      bastion_user = "ubuntu"
      bastion_private_key = "${var.private_key}"
    }
  }

}
