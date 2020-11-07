variable "lb_listener_certificate_arn" {
  description = "The arn for the load balancer listener ssl certificate."
  type        = string
}

variable "name_prefix" {
  default = "The name prefix of the resources created in this module."
  type    = string
}

variable "container_cpu" {
  description = "The amount of cpu to allocate to the task"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The amount of memory to allocate to the task"
  type        = number
  default     = 512
}

variable "container_image" {
  description = "The docker image to run for the task"
  type        = string
}

variable "container_environment_variables" {
  description = "The environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = []
}

variable "log_group_name" {
  description = "The name of the log group for the container"
  type        = string
}

variable "log_group_region" {
  description = "The name of the log group for the container"
  type        = string
}

variable "task_policy_arn" {
  description = "The arn of the task policy"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the ECS Fargate Cluster"
  type        = string
}

variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target for ECS Fargate service"
  default     = 5
  type        = number
}

variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target for ECS Fargate service"
  default     = 1
  type        = number
}