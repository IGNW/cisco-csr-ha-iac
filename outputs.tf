output "node1_public_ip_address" {
  value = "${module.instance1.public_ip}"
}
output "node2_public_ip_address" {
  value = "${module.instance2.public_ip}"
}
output "csr1000v_instance_profile" {
  value = "${aws_iam_instance_profile.csr1000v[0].name}"
}

output "output_script" {
  value = local.output_script
}
