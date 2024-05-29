# EC2 인스턴스 AMI ID를 위한 Data Source 조회
# Amazon Linux 2023 AMI


data "aws_ami" "amazonLinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # 소유자 계정
}

# EC2 생성

resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazonLinux.id # 리전마다 다른 ami id를 해결함
  instance_type = "t2.micro"

  tags = {
    Name = "myInstance"
  }
}