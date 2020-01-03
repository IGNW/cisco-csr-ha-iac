resource "null_resource" "config_script" {
  # Changes to any instance of interfaces
  triggers = {
    vars     = "${jsonencode(local.template_vars)}"
    template = "${data.template_file.ha_configure_script.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.ha_configure_script.rendered}' > tmpscript && chmod 700 tmpscript && ./tmpscript"
  }

}

locals {
  template_vars = {
    node1_public_ip            = "${join("", "${module.instance1.public_ip}")}"
    node2_public_ip            = join("", "${module.instance2.public_ip}")
    node1_tunnel1_ip_and_mask  = "${var.node1_tunnel1_ip_and_mask}"
    node2_tunnel1_ip_and_mask  = "${var.node2_tunnel1_ip_and_mask}"
    tunnel1_subnet_ip_and_mask = "${var.tunnel1_subnet_ip_and_mask}"
    node1_eth1_private         = "${aws_network_interface.csr1000v1eth1.private_ip}"
    node2_eth1_private         = "${aws_network_interface.csr1000v2eth1.private_ip}"
    private_rtb                = "${aws_route_table.private.id}"
    node1_eth1_eni             = "${aws_network_interface.csr1000v1eth1.id}"
    node2_eth1_eni             = "${aws_network_interface.csr1000v2eth1.id}"
    ssh_key                    = "${base64decode(var.base64encoded_ssh_private_key)}"
  }
}

data "template_file" "ha_configure_script" {
  template = "${file("${path.module}/init.sh.tpl")}"
  vars     = "${local.template_vars}"
}
