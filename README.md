# AWS EC2 CSR HA Terraform Module

Terraform module which creates two redundant CSRvs

## Usage

```hcl
module CSRV_HA {
  source                                    = "github.com/IGNW/cisco-csr-ha-iac"
  base64encoded_private_ssh_key             = "${var.base64encoded_private_ssh_key}"
  base64encoded_public_ssh_key             = "${var.base64encoded_public_ssh_key}"
  availability_zone                         = "us-west-2a"
  node1_tunnel1_ip_and_mask                 = "192.168.101.1 255.255.255.252"
  node2_tunnel1_ip_and_mask                 = "192.168.101.2 255.255.255.252"
  tunnel1_subnet_ip_and_mask                = "192.168.101.0 0.0.0.255"
  private_vpc_cidr_block                    = "10.16.0.0/16"
  node1_eth1_private_ip                     = "10.16.3.252"
  node2_eth1_private_ip                     = "10.16.4.253"
  node1_private_subnet_cidr_block           = "10.16.3.0/24"
  node2_private_subnet_cidr_block           = "10.16.4.0/24"
  node1_public_subnet_cidr_block            = "10.16.1.0/24"
  node2_public_subnet_cidr_block            = "10.16.2.0/24"
  public_route_table_allowed_cidr           = "0.0.0.0/0"
  public_security_group_ingress_cidr_blocks = ["0.0.0.0/0"]
  public_security_group_egress_rules        = ["all-all"]
  ssh_ingress_cidr_block                    = ["0.0.0.0/0"]
  public_security_group_ingress_rules       = ["https-443-tcp", "http-80-tcp", "all-icmp"]
  instance_type                             = "c4.large"
}
```
## Required Inputs

The following input variables are required:

### base64encoded\_ssh\_private\_key

Description: base64 encoded private key to use for terraform to connect to the router

Type: `string`

### base64encoded\_ssh\_public\_key

Description: base64 encoded public key to use for terraform to connect to the router

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### availability\_zone

Description: The AWS zone to setup your CSR1000V Highly Available Routers

Type: `string`

Default: `"us-west-2a"`

### instance\_type

Description: Machine size of the routers

Type: `string`

Default: `"c4.large"`

### node1\_eth1\_private\_ip

Description: Private ip address of the internal network interface on Node1

Type: `string`

Default: `"10.16.3.252"`

### node1\_private\_subnet\_cidr\_block

Description: Private ip cidr\_block for the node1 subnet

Type: `string`



## Authors

Module managed by [IGNW](https://github.com/ignw).

## License

Apache 2 Licensed. See LICENSE for full details.
