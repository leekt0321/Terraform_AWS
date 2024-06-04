terraform {
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
}

module "myDB" {
  source = "../modules/db"
  dbuser = "admin"
  dbpassword = "password"
}
