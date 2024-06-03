terraform {
  backend "s3" {
    bucket         = "mybucket-lee-2952"
    key            = "global/s3/terraform.tfstate" # 키 저장할 파일 위치
    region         = "us-east-2"
    dynamodb_table = "myLocks"
  }
}


provider "aws" {
  region = "us-east-2"
}

# instance create
data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "myinstance" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"

  tags = {
    Name = "myinstance"
  }
}

