variable "student_ami" {
  description = "AMIs by region"
  default = {
    us-west-2 = "ami-14348d6c"
  }
}

variable "vpc_cidr" {
  description = "CIDR for whole VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.1.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.1.2.0/24"
}
