variable "project_name" {
  description = "Project name used in naming resources"
  type        = string
}

variable "db_name" {
  description = "Name of the MySQL database to create"
  type        = string
}

variable "username" {
  description = "Username for MySQL master user"
  type        = string
}

variable "db_az" {
  description = "Availability Zone for the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks allowed to access RDS"
  type        = string
}

