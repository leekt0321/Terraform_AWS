# 프로바이더(리전) 설정
provider "aws" {
  region = "us-east-2"
}

# DB 인스턴스 생성
resource "aws_db_instance" "mtdb_instance" {
  allocated_storage    = 10 # 10GB
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  username             = var.dbuser
  password             = var.dbpassword
  
}