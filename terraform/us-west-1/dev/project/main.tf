######################################################### provider blocks ##################################################################

provider "aws" {
  region = var.region
}

terraform {
  required_version = "= 1.11.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.19.0"
    }
  }
}


######################################################### Backend block ####################################################################

####################################### variable name or local attribute doesn't work here ##################################################

terraform {
  backend "s3" {
    bucket       = "bucket-dev-project-terraform-state"
    key          = "dev/shared/terraform.tfstate"
    region       = "us-west-1"
    use_lockfile = true
  }
}

################################################################# variables  ##############################################################



############################################################# common variables ##############################################################

variable "tags" {
  type = map(string)
  default = {
    owner = "project"
    iaac  = "terraform"
  }
}

variable "region" {}

locals {
  env_name = element(split("/", abspath(path.module)), length(split("/", abspath(path.module))) - 2)
  tags     = merge(var.tags, { environment = "${local.env_name}" })
}

########################################################### vpc #############################################################################

variable "cidr" {}

variable "azs" {
  default = ["us-west-1a", "us-west-1b"]
}

variable "private_subnets" {}

variable "database_subnets" {}

variable "public_subnets" {}

########################################################### jenkins #########################################################################

variable "jenkins_vol_size" {
  description = "size for jenkins volume in gb"
  default     = 100
}


variable "jenkins_instance_type" {
  description = "instance type of jenkins server"
  default     = "t3a.xlarge"
}
