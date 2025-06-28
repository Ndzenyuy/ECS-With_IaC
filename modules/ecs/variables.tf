variable "project_name" {}
variable "container_image" {}
variable "container_cpu" {}
variable "container_memory" {}
variable "container_port" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "log_group_name" {}
variable "region" {}

