# cisco-csr-ha-iac
Two VPCS peered to allow Active/Passive HA between Instances

Notes:

- Switching to `local dev` on this branch. `Master` contains work for Terraform Cloud, ~~which is currently being remediated with a Hashicorp ticket.~~ which I  will leave in place until the bad access key issue is solved. Remediation efforts will continue on the `local_dev` branch, with the iterations on my local machine .

# Current Issue

- Unable to stand up an ec2 via Terraform. Instance can be created manually (with proper tagging).
- Error message: 
  - `Error launching source instance: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message:`
  - Decoded error message shows an unknown access key attempting authorization. Access key does not belong to anyone in IGNW org.

# Remeditaion:

- Moved project from Terraform Cloud to local dev; same error
- 



# Image

- We are using [Cisco Cloud Services Router (CSR) 1000V - BYOL for Maximum Performance](https://aws.amazon.com/marketplace/pp/B00NF48FI2?ref=cns_srchrow#pdp-usage) from the marketplace for the HA pair instances. Details:

  - **Name:** cisco-CSR-.16.12.01a-BYOL-HVM-2
  - **AMI Name:** cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4
  - **AMI ID:** ami-0ea109acd52c4b94d
  - **Source:** aws-marketplace/cisco-CSR-.16.12.01a-BYOL-HVM-2-624f5bb1-7f8e-4f7c-ad2c-03ae1cd1c2d3-ami-0a35891127a1b85e1.4
  - **Owner:** 679593333241
