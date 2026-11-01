variable "aws_region" {
  description = "AWS region for the project."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used for local Terraform operations."
  type        = string
  default     = "project1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}
variable "project_name" {
  description = "Short name used for project resources."
  type        = string
  default     = "aws-cloud-project-portfolio"
}

variable "enable_ecs_service" {
  description = "Create the public ALB and running ECS service. Disabled by default to avoid recurring compute and ALB charges."
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Create the Amazon RDS MySQL instance. Disabled by default to avoid recurring database charges."
  type        = bool
  default     = false
}

variable "enable_database_secrets" {
  description = "Create and manage database credentials in AWS Secrets Manager. Disabled by default to avoid recurring secret charges."
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "Compute and memory capacity class of the RDS MySQL instance."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in gigabytes for the RDS MySQL instance."
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance."
  type        = string
  default     = "task_user"
}

variable "container_image_tag" {
  description = "Immutable ECR image tag to deploy. Supply a commit SHA or release version, never a mutable tag."
  type        = string
  default     = "replace-with-immutable-image-tag"

  validation {
    condition     = var.container_image_tag != "latest"
    error_message = "container_image_tag must be an immutable tag, not latest."
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the HTTPS ALB listener. Required when enable_ecs_service is true."
  type        = string
  default     = null
}

variable "database_host" {
  description = "Private DNS name or endpoint of the MySQL database. Required when enable_ecs_service is true."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name of the MySQL database used by the API."
  type        = string
  default     = "tasks_db"
}

variable "database_port" {
  description = "Port of the MySQL database."
  type        = number
  default     = 3306
}

variable "database_credentials_secret_arn" {
  description = "Secrets Manager ARN containing JSON keys username and password. Required when enable_ecs_service is true."
  type        = string
  default     = null
  sensitive   = true
}
