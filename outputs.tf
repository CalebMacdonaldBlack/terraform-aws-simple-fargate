output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "alb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.lb.zone_id
}