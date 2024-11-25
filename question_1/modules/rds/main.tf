resource "random_string" "postgress_db_password" {
  length  = 32
  special = false
}

resource "aws_db_instance" "master_db" {
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.4.13"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = random_string.postgress_db_password.result
  parameter_group_name   = "default.mariadb10.4"
  vpc_security_group_ids = var.rds_sg_id
  db_subnet_group_name   = var.rds_subnet_group_name
  publicly_accessible    = false
  storage_type           = "gp2"
  multi_az               = true
  tags = {
    Name = "${var.rds_instance_name}_MASTER"
  }
}

resource "aws_db_instance" "replica_db" {
  replicate_source_db    = aws_db_instance.master_db.id
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.4.13"
  instance_class         = "db.t2.micro"
  db_subnet_group_name   = var.rds_subnet_group_name
  vpc_security_group_ids = var.rds_sg_id
  storage_type           = "gp2"
  multi_az               = true
  tags = {
    Name = "${var.rds_instance_name}_REPLICA"
  }
}





