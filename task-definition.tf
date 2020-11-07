#------------------------------------------------------------------------------
# AWS ECS Task Execution Role
#------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.name_prefix}-ecs-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.name_prefix}-role-policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachement" {
  policy_arn = var.task_policy_arn
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions    = <<EOF
[
  {
    "name": "${var.name_prefix}",
    "image": "${var.container_image}",
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "environment": ${jsonencode(concat([{name = "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI", value = "creds"}], var.container_environment_variables))}
    ,
    "cpu": ${var.container_cpu},
    "memory": ${var.container_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.log_group_name}",
        "awslogs-region": "${var.log_group_region}",
        "awslogs-stream-prefix": "${var.name_prefix}"
      }
    }
  }
]
EOF

}
