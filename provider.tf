#provider "aws" {
#  region = "us-west-2"
#}


provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "/Users/.aws/creds"
  profile                 = "default"
}