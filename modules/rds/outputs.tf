# outputs.tf
output "vpc_id" {
  value = module.network.vpc_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "db_host" {
  value = module.db.db_instance_address
}