# main.tf (top of the file)
terraform {
  backend "s3" {
    bucket         = "cf-templates-ub6fcrxn86ye-us-east-1"
    key            = "ecs/deployment/terraform.tfstate"
    region         = "us-east-1"    
    use_lockfile = true    
  }
}

module "network" {
  source = "./modules/network"
  project_name = var.project_name
}

module "iam" {
  source = "./modules/iam"
  project_name = var.project_name
}

module "ecs" {
  source           = "./modules/ecs"
  project_name     = var.project_name
  container_image  = var.container_image
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  container_port   = var.container_port
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.public_subnet_ids
  security_group_id = module.network.ecs_security_group_id
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  log_group_name = module.ecs.log_group.name
  region             = var.region
}

module "db" {
  source         = "./modules/rds"
  project_name   = var.project_name
  db_password    = var.db_password
  db_az          = var.db_az
  vpc_id         = module.network.vpc_id
  subnet_ids = [module.network.private_subnet_ids[0]] 
  security_group_id = module.network.rds_security_group_id
}



