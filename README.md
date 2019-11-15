# cisco-csr-ha-iac
Module to HA two instances of a CSR 1000v. 

# AMI

- We are using [Cisco Cloud Services Router (CSR) 1000V - BYOL for Maximum Performance](https://aws.amazon.com/marketplace/pp/B00NF48FI2?ref=cns_srchrow#pdp-usage) from the marketplace for the HA pair instances. Details:

  - **Name:** cisco-CSR-.16.12.01a-BYOL-HVM-2
  - **AMI Name:** cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4
  - **AMI ID:** ami-0ea109acd52c4b94d
  - **Source:** aws-marketplace/cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4
  - **Owner:** 679593333241

# Phase I Goal

1-for-1 Redundancy Topology: Both the Cisco CSR 1000v routers have a direct connection to the same subnet, the routers provide a 1-for-1 redundancy (Active-Passive mode); that is, the active Cisco CSR 1000v router is the next-hop router for a subnet. The other Cisco CSR 1000v router is the passive router for all the routes.


# Current State

Two VPCs (East and West) have been established, along with VPC peering between and Instance_West of the CSR 1000v. (Note: Peering is not necessary for this phase but has been added in advance.)
 
# TODO

- Drop in Instance_East: eC2 using the Cisco CSR image above. The is the passive node in the HA pair.
- Add SSH keys for both instances
- ELB between Instance_East and Instance_West
- Lambda to monitor failover event and provide failover instance with Cisco CSR config
- S3 Bucket to hold Cisco config


# Resources

  - Main Confluence page for Project:

  [Cisco CSR 1000V Project - AWS Network Design](https://ignwsolutions.atlassian.net/wiki/spaces/CUS/pages/291176484/Cisco+CSR+1000V+Project+-+AWS+Network+Design)


# Tooling


Current development is in Terraform Cloud at the following workspace:

https://app.terraform.io/app/IGNW-TEST/workspaces/cisco-csr-ha-iac/runs

All code is in the current repo