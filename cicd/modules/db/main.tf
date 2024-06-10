provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_security_group" "dbSG" {
  name = "dbSG"
  vpc_id = var.vpc_id

  ingress {
    description="allow 3306"
    from_port=3306
    to_port=3306
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }

  egress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
  }

  tags = {
    Name = "dbSG"
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name = "mydb_subnet_group"
  subnet_ids = [var.myPrivate1_id, var.myPrivate2_id]

  tags = {
    Name = "mydb_subnet_group"
  }
}

resource "aws_db_instance" "mydb_instance" {
  allocated_storage = 10
  db_name = "mydb"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true

  username = var.dbuser
  password = var.dbpassword

  depends_on = [ aws_db_subnet_group.mydb_subnet_group ]
  vpc_security_group_ids = [aws_security_group.dbSG.id]
  db_subnet_group_name = aws_db_subnet_group.mydb_subnet_group.name

  tags = {
    Name = "mydb_instance"
  }
}