resource "null_resource" "iface1" {
  # Changes to any instance of interfaces
  triggers = {
    #vars     = jsonencode(local.template_vars)
    vars     = "as"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.ha_configure_script.rendered}' > tmpscript && chmod 700 tmpscript && ./tmpscript"
  }

}

locals {
  template_vars = {
    csrv1_public_ip    = join("", "${module.instance1.public_ip}")
    csrv2_public_ip    = join("", "${module.instance1.public_ip}")
    csrv1_eth1_private = "${aws_network_interface.csr1000v1eth1.private_ip}"
    csrv2_eth1_private = "${aws_network_interface.csr1000v2eth1.private_ip}"
    private_rtb        = "${aws_route_table.private.id}"
    csrv1_eth1_eni     = "${aws_network_interface.csr1000v1eth1.id}"
    csrv2_eth1_eni     = "${aws_network_interface.csr1000v2eth1.id}"
    ssh_key            = "${base64decode(var.base64encoded_ssh_key)}"
  }
}

data "template_file" "ha_configure_script" {
  template = "${file("${path.module}/init.sh.tpl")}"
  vars     = "${local.template_vars}"
}
