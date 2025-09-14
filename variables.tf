variable "region" {
  description = "AWS region (Academy usa us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "image_uri" {
  description = "ECR Image URI (ej: 123456789012.dkr.ecr.us-east-1.amazonaws.com/api-students:latest)"
  type        = string
}

variable "lab_role_arn" {
  description = "ARN del rol existente LabRole (arn:aws:iam::<ACCOUNT_ID>:role/LabRole)"
  type        = string
}

variable "container_port" {
  description = "Puerto en el que escucha tu app"
  type        = number
  default     = 8000
}

variable "desired_count" {
  description = "Cantidad de tareas en el servicio"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Ruta del health check del ALB Target Group"
  type        = string
  default     = "/students"
}

variable "vpc_id" {
  description = "VPC ID (por ej. vpc-0abc123def...)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets PÚBLICAS de esa VPC (2 o más)"
  type        = list(string)
}
