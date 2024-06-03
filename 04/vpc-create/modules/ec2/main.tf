data "aws_ami" "ubuntu2204" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  count = 2

  ami = data.aws_ami.ubuntu2204.id
  instance_type = var.instance_type
  # (required) Subnet 지정
  subnet_id = var.subnet_id

  tags = var.instance_tags
}

