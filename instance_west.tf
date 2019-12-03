### New interfaces
### "Outside"  Interface publicly available 80 and 443 open to any (DHCP supplied)
##  Next hop interface. 
##  The subnet id will reference the appropriate network the router is in. Should be same vpc as the internet gateway
##    Should be part of the security group for outside traffic in the 80 and 443
#DEFAULT ## "Inside"   Inteface privately connected to Subnet both of them are on (manually supplied)
##  Should have all and all allowed for the traffic in the subnet
##  
### "Failover" Interface to connect to eachother
#
#
### Firewall Rules that need to be made
### "Port"     UDP 4789 4790 between them 
### Outside interface will need 80 and 443 opened up
### Internet gateway will need to be created for use by the routers (to ingest the tables)
### "internet gateway" csr_public_rtb 
##
##mode should be primary on 1 and secondary on 2
#
##For next hop interface it would be the public interface
#
#data "aws_ami" "csr_west" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["679593333241"] # Cisco
#
#}
#
#resource "aws_security_group" "ssh_in" {
#  description = "Highly insecure SG permitting SSH"
#  name        = "allow-ssh-sg_west"
#  vpc_id      = "${module.vpc-west.vpc_id}"
#
#  ingress {
#    # TLS (change to whatever ports you need)
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    # Please restrict your ingress to only necessary IPs and ports.
#    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#
#
#resource "aws_instance" "csr_west" {
#  ami           = "${data.aws_ami.csr_west.id}"
#  instance_type = "t2.medium"
#  key_name      = "csr1000v"
#}
