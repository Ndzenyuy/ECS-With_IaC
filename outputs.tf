
# outputs.tf (optional)
output "vpc_id" {
  value = module.network.vpc_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "db_host" {
  value = module.rds.db_instance_address
}

