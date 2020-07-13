

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}

# module "aws_master" {
#   source  = "./aws/master"
# }


terraform {
  backend "s3" {
    profile = "terraform"
    encrypt = "true"
    bucket  = "pablosls-bucket-state-terraform"
    region  = "us-east-1"
    key     = "global/terraform.tfstate"
  }
}




