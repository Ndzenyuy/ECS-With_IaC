# main.tf (top of the file)
terraform {
  backend "s3" {
    bucket       = "cf-templates-ub6fcrxn86ye-us-east-1"
    key          = "ecs/deployment/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

module "network" {
  source       = "./modules/network"
  project_name = var.project_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecs" {
  source             = "./modules/ecs"
  project_name       = var.project_name
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory  
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_id  = module.network.ecs_security_group_id
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  region             = var.region
  webapi_image =  var.webapi_image
  nginx_image = var.nginx_image
  api_image = var.api_image
  client_image = var.client_image
  nginx_container_port = var.nginx_container_port
  api_container_port = var.api_container_port
  webapi_container_port = var.webapi_container_port
  client_container_port    = var.client_container_port  
}

module "db" {
  source = "./modules/rds"

  project_name           = var.project_name
  db_name                = "books"
  username               = "root"
  password               = var.db_password
  db_az                  = module.network.private_subnet_az
  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  ecs_security_group_id  = module.network.ecs_security_group_id
}

