# AWS ALB Terraform Module

A simple module that creates a https application load balancer using the default vpc and subnets.

## Usage

```hcl
module "aws_simple_alb" {
  source = "github.com/CalebMacdonaldBlack/terraform-aws-simple-alb"

  lb_listener_certificate_arn = var.alb_certificate_arn
}
```
