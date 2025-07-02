data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "ssm_access" {
  name = "ecs-ssm-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["ssm:GetParameter", "ssm:GetParameters"],
      Resource = [
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/MONGO_URI",
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/DB_PASS"
      ]
    }]
  })
}



resource "aws_iam_role" "execution" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  for_each = {
    task_execution_role_policy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    task_ssm_policy = aws_iam_policy.ssm_access.arn
  }
  # Using for_each to iterate over a map of policies
  # This allows for easy addition or removal of policies in the future
  role       = aws_iam_role.execution.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "task_role_attachments" {
  for_each = {
    ecr_access              = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    cloudwatch_access       = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    service_discovery_access = "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
    task_ssm_policy = aws_iam_policy.ssm_access.arn
  }

  role       = aws_iam_role.task.name
  policy_arn = each.value
}