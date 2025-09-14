provider "aws" { region = var.region }

data "aws_vpc" "default" { default = true }
data "aws_subnets" "vpc" { filter { name = "vpc-id" values = [data.aws_vpc.default.id] } }
data "aws_subnet" "by_id" {
  for_each = toset(data.aws_subnets.vpc.ids)
  id       = each.value
}
locals {
  public_subnet_ids = [for s in data.aws_subnet.by_id : s.id if s.map_public_ip_on_launch]
  vpc_id            = data.aws_vpc.default.id
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB SG"
  vpc_id      = local.vpc_id
  ingress { from_port=80 to_port=80 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "svc" {
  name        = "svc-sg"
  description = "Service SG"
  vpc_id      = local.vpc_id
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_lb" "this" {
  name               = "api-students-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name        = "api-students-tg"
  vpc_id      = local.vpc_id
  target_type = "ip"
  port        = var.container_port
  protocol    = "HTTP"
  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.this.arn }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/api-students-tf"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "this" {
  name = "api-students-tf-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "api-students-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn

  container_definitions = jsonencode([{
    name      = "api-students"
    image     = var.image_uri
    essential = true
    portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = "api-students-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = local.public_subnet_ids
    security_groups  = [aws_security_group.svc.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "api-students"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}
