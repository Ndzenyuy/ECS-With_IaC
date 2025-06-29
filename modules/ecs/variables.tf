variable "project_name" {}
variable "container_cpu" {}
variable "container_memory" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "log_group_name" {}
variable "region" {}

variable "api_image" {}
variable "webapi_image" {}
variable "nginx_image" {}
variable "client_image" {}

variable "api_container_port" {}
variable "webapi_container_port" {}
variable "nginx_container_port" {}
variable "client_container_port" {}