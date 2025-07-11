output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_subnet_az" {
  value = aws_subnet.private[0].availability_zone
}


