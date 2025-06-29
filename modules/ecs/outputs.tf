output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "log_group_api" {
  value = aws_cloudwatch_log_group.api
}
output "log_group_webapi" {
  value = aws_cloudwatch_log_group.webapi
}
output "log_group_client" {
  value = aws_cloudwatch_log_group.client
}
output "log_group_nginx" {
  value = aws_cloudwatch_log_group.nginx
}
