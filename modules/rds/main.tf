resource "aws_security_group" "rds" {
  name        = "rds-access"
  description = "Allow MySQL access from ECS only"
  vpc_id      = var.vpc_id
  

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.0.2"

  identifier        = "books"
  engine            = "mysql"
  engine_version    = "8.0.41"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name                = var.db_name
  username               = var.username
  password = var.password
  port     = 3306

  vpc_security_group_ids = [aws_security_group.rds.id]

  create_db_subnet_group = true
  subnet_ids = var.private_subnet_ids


  family                  = "mysql8.4"
  major_engine_version    = "8.0"
  deletion_protection     = false
  backup_retention_period = 0
  monitoring_interval     = 0
  create_monitoring_role  = false
  skip_final_snapshot     = true

  availability_zone = var.db_az

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}

resource "null_resource" "init_db" {
  depends_on = [module.db]

  provisioner "local-exec" {
    command = <<EOT
mysql -h ${module.db.db_instance_address} -P 3306 -u user -p${var.password} -e "CREATE TABLE IF NOT EXISTS books (id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(255));" demodb
EOT
  }
}



