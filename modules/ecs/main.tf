
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "ecs-microservice-ns"
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

  health_check_custom_config {

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

  health_check_custom_config {

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

  health_check_custom_config {

  }
}


resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-Cluster"
}


### cloudwatch log groups
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/api"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "webapi" {
  name              = "/ecs/webapi"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "client" {
  name              = "/ecs/client"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/nginx"
  retention_in_days = 30
}

#####   data sources for environment variables

data "aws_ssm_parameter" "mongo_uri" {
  name = "MONGO_URI"
}
data "aws_ssm_parameter" "db_password" {
  name = "DB_PASS"
}



#####Task definitions
#client
resource "aws_ecs_task_definition" "client" {
  family                   = "${var.project_name}-client-Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "client"
    image     = var.client_image
    essential = true
    portMappings = [{
      containerPort = var.client_container_port
      hostPort      = var.client_container_port
      protocol      = "tcp"
    }],
    cpu    = var.container_cpu
    memory = var.container_memory
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



#api
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api-Task"
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
    secrets = [
      {
        name      = "MONGO_URI"
        valueFrom = data.aws_ssm_parameter.mongo_uri.arn
      }
    ]

    portMappings = [{
      containerPort = var.api_container_port
      hostPort      = var.api_container_port
      protocol      = "tcp"
    }],
    cpu    = var.container_cpu
    memory = var.container_memory
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.api.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

#webapi
resource "aws_ecs_task_definition" "webapi" {
  family                   = "${var.project_name}-webapi-Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "webapi"
    image     = var.webapi_image
    essential = true
    environment = [
      {
        name      = "MYSQL_HOST"
        value = var.db_instance_address
      },
      {
        name      = "MYSQL_USER"
        value = var.username
      },
      {
        name      = "MYSQL_DB"
        value = var.db_name
      }
    ]
    secrets = [
      {
        name      = "DB_PASS"
        valueFrom = data.aws_ssm_parameter.db_password.arn
      },
      {
        name      = "MONGO_URI"
        valueFrom = data.aws_ssm_parameter.mongo_uri.arn
      }
    ]

    portMappings = [{
      containerPort = var.webapi_container_port
      hostPort      = var.webapi_container_port
      protocol      = "tcp"
    }],
    cpu    = var.container_cpu
    memory = var.container_memory
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.webapi.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# Load balancer
resource "aws_lb" "nginx-lb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids
}

#Target group
resource "aws_lb_target_group" "nginx-tg" {
  name        = "${var.project_name}-tg"
  port        = var.nginx_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # FARGATE requires "ip" target type
  health_check {
    path = "/"
  }
}

# Listener
resource "aws_lb_listener" "nginx-listener" {
  load_balancer_arn = aws_lb.nginx-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}


#nginx
resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-nginx-Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "nginx"
    image     = var.nginx_image
    essential = true
    portMappings = [{
      containerPort = var.nginx_container_port
      hostPort      = 0
      protocol      = "tcp"
    }],
    cpu    = var.container_cpu
    memory = var.container_memory
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.nginx.name
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
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client.arn
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-Service-api"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api.arn
  }
}

resource "aws_ecs_service" "webapi" {
  name            = "${var.project_name}-Service-webapi"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.webapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.webapi.arn
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-Service-nginx"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nginx.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-tg.arn
    container_name   = "nginx"
    container_port   = var.nginx_container_port
  }
  depends_on = [aws_lb_listener.nginx-listener]
}