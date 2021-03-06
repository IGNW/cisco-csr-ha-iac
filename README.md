# AWS EC2 CSR HA Terraform Module

Terraform module which creates an HA Pair of two CSR 1000V soft switches in AWS.
<br>[AWS CSR 1000V Marketplace Document](https://aws.amazon.com/marketplace/pp/B00OCG4Q4E)

### IMPORTANT!
This terraform module output a series of generated commands that require being run, you will have to have the ssh key you provided named csr.pem in the directory in which you run these scripts. Terraform could not run these due to the CSR ami handing the ssh session over to a telnet session.

## Usage

```hcl
module CSRV_HA {
  source                                    = "github.com/IGNW/cisco-csr-ha-iac"
  base64encoded_private_ssh_key             = "${var.base64encoded_private_ssh_key}"
  base64encoded_public_ssh_key              = "${var.base64encoded_public_ssh_key}"
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability\_zone | The AWS zone to setup your CSR1000V Highly Available Routers | string | `"us-west-2a"` | no |
| aws\_region | Region for aws | string | `"us-west-2"` | no |
| base64encoded\_ssh\_private\_key | base64 encoded private key to use for terraform to connect to the router | string | n/a | yes |
| base64encoded\_ssh\_public\_key | base64 encoded public key to use for terraform to connect to the router | string | n/a | yes |
| aws\_ssh\_keypair\_name | Name of ssh key pair you are putting into aws | string | `<string>` | yes |
| csr1000v\_ami\_filter | Filter to find best match of image | string | `"cisco-CSR-.16.12.01a-AX-HVM-9f5a4516-a4c3-4cf1-89d4-105d2200230e-ami-0f6fdba70c4443b5f.4"` | no |
| csr1000v\_instance\_profile | Only for using existing instance profiles to pass to the csr1000v ha module, or when using multiple instances of this module | string | n/a | no |
| instance\_type | Machine size of the routers | string | `"c4.large"` | no |
| node1\_eth1\_private\_ip | Private ip address of the internal network interface on Node1 | string | `"10.16.3.252"` | no |
| node1\_private\_subnet\_cidr\_block | Private ip cidr\_block for the node1 subnet | string | `"10.16.3.0/24"` | no |
| node1\_public\_subnet\_cidr\_block | Public ip cidr\_block for the node1 subnet | string | `"10.16.1.0/24"` | no |
| node1\_tunnel1\_ip\_and\_mask | The address of the tunnel for CSRV number 1 | string | `"192.168.101.1 255.255.255.252"` | no |
| node2\_eth1\_private\_ip | Private ip address of the internal network interface on Node2 | string | `"10.16.4.253"` | no |
| node2\_private\_subnet\_cidr\_block | Private ip cidr\_block for the node2 subnet | string | `"10.16.4.0/24"` | no |
| node2\_public\_subnet\_cidr\_block | Public ip cidr\_block for the node2 subnet | string | `"10.16.2.0/24"` | no |
| node2\_tunnel1\_ip\_and\_mask | The address of the tunnel for CSRV number 2 | string | `"192.168.101.2 255.255.255.252"` | no |
| private\_vpc\_cidr\_block | Cidr block for the entire vpc | string | `"10.16.0.0/16"` | no |
| public\_route\_table\_allowed\_cidr | Allowed cidr\_block for connections from the public network interface route table | string | `"0.0.0.0/0"` | no |
| public\_security\_group\_egress\_rules | Allowed cidr\_block for connections from the public | list(string) | `<list>` | no |
| public\_security\_group\_egress\_rules | Allowed cidr\_block for connections from the public | list(string) | `<list>` | no |
| public\_security\_group\_ingress\_cidr\_blocks | Allowed cidr\_block for connections to the public network | list(string) | `<list>` | no |
| public\_security\_group\_ingress\_rules | Rules allowed to public network | list(string) | `<list>` | no |
| ssh\_ingress\_cidr\_block | Address block from which ssh is allowed | list(string) | `<list>` | no |
| tunnel1\_subnet\_ip\_and\_mask | The address of the tunnel and the subnet mask | string | `"192.168.101.0 0.0.0.255"` | no |


## Outputs

| Name | Description |
|------|-------------|
| node1\_public\_ip\_address |  |
| node2\_public\_ip\_address |  |
| csr1000v\_instance\_profile |  |

## Extra
To see the relationship map open graph.svg in a browser

## Authors

Module managed by [IGNW](https://github.com/ignw).

## License

kpache 2 Licensed. See LICENSE for full details.
