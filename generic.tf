variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc" {
  type = string
}

variable "gatewaynet" {
  type = string
}

variable "servicenet" {
  type = string
}

variable "nlbA" {
  type = string
}

variable "instanceA" {
  type = string
}

variable "vendor_ami_account_number" {
  type        = string
  description = "The account number of the vendor supplying the base AMI"
}

variable "vendor_ami_name_string" {
  type        = string
  description = "The search string for the name of the AMI from the AMI Vendor"
}

variable "ssh_key" {
  type = string
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "azs" {
  state = "available"
}

# account id
data "aws_caller_identity" "aws-account" {
}


# aws, gov, or cn
data "aws_partition" "aws-partition" {
}

# random string as suffix
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

variable "name_prefix" {
  type = string
}

variable "service_clients" {
  type    = list(any)
  default = []
}

variable "service_ports" {
  type    = list(any)
  default = []
}

variable "service_protocol" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_diskgb" {
  type = number
}
