
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "ecs.local"
  vpc         = var.vpc_id
  description = "Private DNS namespace for ECS services"
}

resource "aws_service_discovery_service" "api" {
  name = "api"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

}

resource "aws_service_discovery_service" "client" {
  name = "client"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

  
}

resource "aws_service_discovery_service" "nginx" {
  name = "nginx"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
     = 1
  }
}

resource "aws_service_discovery_service" "webapi" {
  name = "webapi"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

 
}


resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-Cluster"
}


### cloudwatch log groups
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "webapi" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "client" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}


#####Task definitions

resource "aws_ecs_task_definition" "client" {
  family                   = "${var.project_name}-Task:api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "api"
    image     = var.api_image
    essential = true
    portMappings = [{
      containerPort = var.client_container_port
      hostPort      = var.client_container_port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.client.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

#### Services


resource "aws_ecs_service" "client" {
  name            = "${var.project_name}-Service-client"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.client.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client.arn
  }
}

