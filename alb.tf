resource "aws_security_group" "lb" {
  name = "${var.name_prefix}-lb-security-group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_lb" "lb" {
  name               = "${var.name_prefix}-alb"
  subnets            = data.aws_subnet_ids.default_subnet_ids.ids
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.name_prefix}-lb-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default_vpc.id
  target_type = "ip"

  health_check {
    path     = "/health"
    protocol = "HTTP"
    port     = 5000
    matcher  = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.lb]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  depends_on        = [
    aws_lb_target_group.lb_target_group]

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    type             = "forward"
  }

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.lb_listener_certificate_arn
}