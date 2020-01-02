module instance1 {
  source                      = "github.com/IGNW/cisco-csr-ha-iac"
  base64encoded_ssh_key       = "${var.base64encoded_ssh_key}"
}
