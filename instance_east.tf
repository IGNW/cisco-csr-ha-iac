# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

data "aws_ami" "csr_east" {
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

  tags = {
    Project = "CSR HA",
    Owner   = "tomc@ignw.io",
    Team    = "DevOps"
    
  }
}

resource "aws_instance" "csr_east" {
  ami           = "${data.aws_ami.csr_east.id}"
  instance_type = "t2.medium"
  key_name      = "csr1000v"

  tags = {
    Project = "CSR HA",
    Owner   = "tylerw@ignw.io",
    Team    = "DevOps"
    
  }
}
