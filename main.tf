resource "aws_cloudformation_stack" "api" {
  name = var.stack_name

  # No creamos IAM; CloudFormation usará solo recursos permitidos
  capabilities = []

  parameters = {
    VpcId           = var.vpc_id
    SubnetIds       = join(",", var.subnet_ids)   # lista separada por comas para CFN
    ImageUri        = var.image_uri
    LabRoleArn      = var.lab_role_arn
    ContainerPort   = var.container_port
    HealthCheckPath = var.health_check_path
    DesiredCount    = var.desired_count
  }

  template_body = file("${path.module}/cfn/ecs-fargate.yml")
}
