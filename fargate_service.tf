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

resource "aws_ecs_service" "service" {
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

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 85
  dimensions          = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_actions       = [aws_appautoscaling_policy.scale_up_policy.arn]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name_prefix}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  dimensions          = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_actions       = [aws_appautoscaling_policy.scale_down_policy.arn]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${var.name_prefix}-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${var.name_prefix}-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.scale_target_min_capacity
  max_capacity       = var.scale_target_max_capacity
}