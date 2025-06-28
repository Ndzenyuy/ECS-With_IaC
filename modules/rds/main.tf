
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.0.2"

  identifier        = "demodb"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3a.large"
  allocated_storage = 20

  db_name  = "demodb"
  username = "user"
  password = var.db_password
  port     = 3306

  vpc_security_group_ids = [aws_security_group.rds.id]

  create_db_subnet_group = true
  subnet_ids             = [module.network.public_subnet_ids[0]]

  family                  = "mysql5.7"
  major_engine_version    = "5.7"
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
mysql -h ${module.db.db_instance_address} -P 3306 -u user -p${var.db_password} -e "CREATE TABLE IF NOT EXISTS books (id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(255));" demodb
EOT
  }
}



