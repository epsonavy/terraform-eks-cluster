resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#$%"
}
resource "aws_db_instance" "database" {
  allocated_storage   = 10
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t2.micro"
  identifier          = "test-db-instance"
  name                = "mydb"
  username            = "admin"
  password            = random_password.password.result
  skip_final_snapshot = true

  tags = {
    Name        = "terraform-eks-demo-db"
    Owner       = "pei.b.liu"
    Environment = "dev"
  }
}