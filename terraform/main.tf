terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-0de5"
    key    = "ecs/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_ecs_cluster" "cluster" {
  name = "helloworld-0de5"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_ecs_task_definition" "task" {
  family                   = "helloworld"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name          = "helloworld"
      image         = "977099019589.dkr.ecr.us-east-2.amazonaws.com/helloworld:latest"
      essential     = true
      portMappings  = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.default.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "helloworld"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-035f229c16d3e5bbb","subnet-0695d9c20ddb0a8fd","subnet-0ccfe9e4791eb332b"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name   = "helloworld"
    container_port   = 5000
  }
}

resource "aws_lb" "app_lb" {
  name               = "helloworldlb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-035f229c16d3e5bbb","subnet-0695d9c20ddb0a8fd","subnet-0ccfe9e4791eb332b"]
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "helloworld-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = "vpc-0508d1abc31012c6f"
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
