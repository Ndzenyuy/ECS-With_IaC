# variables.tf
variable "project_name" {
  default = "catpipeline"
}

variable "container_image" {
  description = "ECR image URI"
  type        = string
}

variable "container_cpu" {
  default = 256
}

variable "container_memory" {
  default = 512
}

variable "container_port" {
  default = 80
}

variable "region" {
  default = "us-east-1"
}

variable "db_password" {
  description = "MySQL password"
  type        = string
  sensitive   = true
}

variable "db_az" {
  description = "Availability zone for RDS"
  type        = string
}
