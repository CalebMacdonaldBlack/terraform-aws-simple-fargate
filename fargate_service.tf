resource "aws_security_group" "service" {
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "TCP"
    security_groups = [aws_security_group.lb.id]
  }
}

resource "aws_ecs_service" "back_end" {
  name            = var.name_prefix
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"
  cluster         = var.ecs_cluster_name
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnet_ids.default_subnet_ids.ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = var.name_prefix
    container_port   = 5000
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}