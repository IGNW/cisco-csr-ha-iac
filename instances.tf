module instance1 {
  #source                      = "terraform-aws-modules/ec2-instance/aws"
  source                      = "github.com/terraform-aws-modules/ec2-instance"
#  version                     = "~> 2.0"
  ami                         = "${data.aws_ami.csr1000v.id}"
  instance_type               = "c4.large"
  subnet_id                   = "${aws_subnet.public1.id}"
  name                        = "csr1000v1"
  key_name                    = "csr"
  iam_instance_profile        = "${aws_iam_instance_profile.csr1000v.name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.security_group_outside.this_security_group_id}", "${module.ssh_security_group.this_security_group_id}"]
}

module instance2 {
  #source                      = "terraform-aws-modules/ec2-instance/aws"
  source                      = "github.com/terraform-aws-modules/ec2-instance"
#  version                     = "~> 2.0"
  associate_public_ip_address = true
  ami                         = "${data.aws_ami.csr1000v.id}"
  name                        = "csr1000v2"
  key_name                    = "csr"
  instance_type               = "c4.large"
  iam_instance_profile        = "${aws_iam_instance_profile.csr1000v.name}"
  subnet_id                   = aws_subnet.public2.id
  vpc_security_group_ids      = ["${module.security_group_outside.this_security_group_id}", "${module.ssh_security_group.this_security_group_id}"]
}

data "aws_ami" "csr1000v" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cisco-CSR-.16.12.01a-AX-HVM-9f5a4516-a4c3-4cf1-89d4-105d2200230e-ami-0f6fdba70c4443b5f.4"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Cisco

}

