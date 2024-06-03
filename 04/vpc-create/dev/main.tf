provider "aws" {
  region = "ap-northeast-2"
}

module "myVPC" {
  source = "../modules/vpc"
  public_subnet = "10.0.2.0/24"
  az = "ap-northeast-2c"
  
}

module "myEC2" {
  source = "../modules/ec2"
  subnet_id = module.myVPC.subnet_id
  instance_tags = {
    Name = "myEC2_tags"
  }
}
