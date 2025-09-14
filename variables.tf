variable "region"           { type = string  default = "us-east-1" }
variable "image_uri"        { type = string  description = "ECR Image URI" }
variable "lab_role_arn"     { type = string  description = "arn:aws:iam::<ACCOUNT_ID>:role/LabRole" }
variable "container_port"   { type = number  default = 8000 }
variable "desired_count"    { type = number  default = 1 }
variable "health_check_path"{ type = string  default = "/students" }
