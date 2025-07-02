# variables.tf
variable "project_name" {
  default = "ECS-with-IaC"
}

variable "container_cpu" {
  default = 256
}

variable "container_memory" {
  default = 512
}

variable "nginx_container_port" {
  default = 80
}
variable "client_container_port" {
  default = 4200
}
variable "api_container_port" {
  default = 5000
}
variable "webapi_container_port" {
  default = 9000
}

variable "region" {
  default = "us-east-1"
}

variable "api_image" {}
variable "webapi_image" {}
variable "nginx_image" {}
variable "client_image" {}
variable "db_name" {}
variable "username" {}



