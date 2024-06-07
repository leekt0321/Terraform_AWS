terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "mybucket-lee-1234"
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "myDyDB"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "myVPC" {
  source = "../modules/vpc"
  address=module.myDB.address
  port = module.myDB.port
}

module "myDB" {
  source = "../modules/db"
  dbuser = "admin"
  dbpassword = "password"
  myPrivate1_id = module.myVPC.myPrivate1_id
  myPrivate2_id = module.myVPC.myPrivate2_id
  vpc_id = module.myVPC.vpc_id
}