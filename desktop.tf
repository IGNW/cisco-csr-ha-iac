resource "aws_instance" "desktop" {
  ami = "ami-b6ca76d6"
  instance_type = "m3.medium"
  count = "${length(var.students)}"
  subnet_id = "${element(aws_subnet.us-west-2b-public.*.id, count.index)}"
  key_name = "student"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${element(aws_security_group.student_router.*.id, count.index)}","${element(aws_security_group.student_node.*.id, count.index)}"]
  private_ip = "10.1.1.100"

  tags = {
    Project = "${var.project}"
    Name = "${var.project} - Desktop - ${element(var.students, count.index)}"
    Student = "${element(var.students, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
# Need to fix AppStream - Updated in 16.10 but not 16.04
      "sudo apt install appstream/xenial-backports",
      "sudo appstreamcli refresh —force",
# Continue into actual update and install
      "sudo apt-get update",
      "sudo apt-get -y install git python3-pip"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${var.private_key}"
      host        = self.public_ip

    }
  }

  provisioner "file" {
    content = "${var.private_key}"
    destination = "/home/ubuntu/.ssh/id_rsa"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${var.private_key}"
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/ubuntu/.ssh/id_rsa"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${var.private_key}"
      host        = self.public_ip
    }
  }

  provisioner "file" {
    content = "${var.public_key}"
    destination = "/home/ubuntu/.ssh/id_rsa.pub"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${var.private_key}"
      host        = self.public_ip
    }
  }

}

#resource "aws_eip" "student-desktop" {
#  vpc = true
#
#  count = "${length(var.students)}"
#  instance = "${element(aws_instance.desktop.*.id, count.index)}"
#}
