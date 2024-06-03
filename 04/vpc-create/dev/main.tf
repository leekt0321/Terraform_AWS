provider "aws" {
  region = "ap-northeast-2"
}

module "myVPC" {
  source = "../modules/vpc"
}

module "myEC2" {
  source = "../modules/ec2"
  subnet_id = module.myVPC.subnet_id
}
