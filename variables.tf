variable "region" {
  type        = string
  description = "AWS region (Academy suele ser us-east-1)"
  default     = "us-east-1"
}

variable "stack_name" {
  type        = string
  description = "Nombre del stack de CloudFormation que gestionará Terraform"
  default     = "api-students-tf-cfn"
}

variable "image_uri" {
  type        = string
  description = "ECR Image URI (p. ej. 123456789012.dkr.ecr.us-east-1.amazonaws.com/api-students:latest)"
}

variable "lab_role_arn" {
  type        = string
  description = "ARN del rol existente LabRole (arn:aws:iam::<ACCOUNT_ID>:role/LabRole)"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC (vpc-xxxxxxxx)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs de 2+ subnets PÚBLICAS de la VPC"
}

variable "container_port" {
  type        = number
  description = "Puerto donde escucha la app"
  default     = 8000
}

variable "health_check_path" {
  type        = string
  description = "Ruta del health check del ALB Target Group"
  default     = "/students"
}

variable "desired_count" {
  type        = number
  description = "Número de tareas en el servicio ECS"
  default     = 1
}
