# AWS Fargate Terraform Module

A simple module that creates a https application load balancer using the default vpc and subnets.

## Usage

```hcl
module "aws_simple_alb" {
  source = "github.com/CalebMacdonaldBlack/terraform-aws-simple-alb"

  lb_listener_certificate_arn = var.service_certificate_arn
  name_prefix                 = "service"
  container_image             = aws_ecr_repository.service.repository_url
  log_group_name              = aws_cloudwatch_log_group.fargate_log_group.name
  log_group_region            = var.aws_region
  task_policy_arn             = aws_iam_policy.task.arn
  ecs_cluster_name            = data.terraform_remote_state.main.outputs.cluster_name

  container_environment_variables = [
    {
      name  = "REDIS_HOST",
      value = aws_elasticache_cluster.redis.cache_nodes[0].address
    },
    {
      name  = "REDIS_PORT",
      value = aws_elasticache_cluster.redis.cache_nodes[0].port
    }
  ]
}
```
