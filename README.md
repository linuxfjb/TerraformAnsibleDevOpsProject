# TerraformAnsibleDevOpsProject
Project 2 from "PG DO - DevOps Certification Training"
The following files can be used for the automated creation of EC2 instances with Jenkins and prereqs.

Terraform:
creds.tf - set this file up with AWS credentials as set up by Simplilearn labs.
main.tf - creates an EC2 running instance including network infrastructure (VPC, subnet, etc)
          and keypairs for ssh access.

Ansible:
hosts - this is the inventory file used to house the IP address of the machine to do the Jenkins installation.
ansiblePythonJavaJenkins.yml - installs Python, Python AWS CLI, Java open JDK8, and Jenkins server
