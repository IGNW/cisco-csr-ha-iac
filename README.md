# IGNW Classroom

## What this is

This chunk of Terraform code is expressly designed to build the IGNW networking
lab in AWS for classrooms.

This code reads an array of student names, and provides each student the following:

* 1 VPC
* 1 Public Gateway
* 1 NAT Node
* 1 Public Subnet (10.1.1.0/24)
* 1 Private Subnet (10.1.2.0/24)
* 1 Public Security Group (Currently ALL/ALL)
* 1 Private Security Group (Intentionally ALL/ALL)
* 1 Student Desktop (10.1.1.100) - With a Public Routed IP Address
* 1 Student Node (10.1.2.100)
* 1 Student Router (10.1.2.101)
* 1 Student ASAv (10.1.2.102)

## How to Use it

### Edit students.tf

Students.tf contains two variables that should be edited:

* `project` - The name or project code of the class being run
* `students` - An array containing the names of each student in the class

There are also two variables that should **NOT** be edited:

* `private_key`: Used to set the private key on all nodes
* `public_key`: Used to set the public key on all nodes

### Run Terraform

A simple `terraform apply` will spin up all resources for the classroom. Be warned,
this can take up to 10 minutes, so it's best to run this as early as possible. Before
the class if possible.

### Delivery

A script has been provided named `student_export.sh`. This script looks for all
Public IPs attached to desktop nodes and attaches them to a name and wraps them
into a simple CSV. It then creates a zip file containing the CSV and the SSH keys
to be distributed via e-mail to the students.

We could definitely use a "How to use this.txt" that is also included in this zip
file, making the instructors life a little easier.

## Dependencies

### AWS CLI Tools
First, ensure you have the AWS CLI tools installed: `https://docs.aws.amazon.com/cli/latest/userguide/installing.html`

* Run: `aws configure` - Follow the prompt to enter in your IGNW AWS Credentials.
Terraform will use these credentials to provision resources

### Terraform Installation
Second, ensure you have terraform installed: `https://www.terraform.io/downloads.html`.
