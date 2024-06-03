provider "aws" {
  region = "ap-northeast-2"
}

module "myVPC" {
  source = "../modules/vpc"
}


