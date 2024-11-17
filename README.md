# infra-cdr-gateway

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ./modules/ecs_modules/ecs_cluster | n/a |
| <a name="module_keycloak_db"></a> [keycloak\_db](#module\_keycloak\_db) | ./modules/rds_modules/rds_db_instance | n/a |
| <a name="module_keycloak_ecs_service"></a> [keycloak\_ecs\_service](#module\_keycloak\_ecs\_service) | ./modules/ecs_modules/ecs_service | n/a |
| <a name="module_keycloak_task_definition"></a> [keycloak\_task\_definition](#module\_keycloak\_task\_definition) | ./modules/ecs_modules/ecs_task_definition | n/a |
| <a name="module_kong_db"></a> [kong\_db](#module\_kong\_db) | ./modules/rds_modules/rds_db_instance | n/a |
| <a name="module_kong_ecs_service"></a> [kong\_ecs\_service](#module\_kong\_ecs\_service) | ./modules/ecs_modules/ecs_service | n/a |
| <a name="module_kong_task_definition"></a> [kong\_task\_definition](#module\_kong\_task\_definition) | ./modules/ecs_modules/ecs_task_definition | n/a |
| <a name="module_subnet_group"></a> [subnet\_group](#module\_subnet\_group) | ./modules/rds_modules/rds_db_subnet_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.kong](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudwatch_log_group.keycloak_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.kong_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_parameter_group.kong](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_iam_role.rds_monitoring_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rds_monitoring_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_vpc_security_group_ingress_rule.kong_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.kong_status_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.keycloak_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.keycloak_master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.kong_master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.rds_monitoring_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_security_group_id"></a> [default\_security\_group\_id](#input\_default\_security\_group\_id) | The default security group ID. | `string` | `"sg-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name. | `string` | `"dev"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The Subnet IDs to deploy resources | `list(string)` | <pre>[<br>  "subnet-1",<br>  "subnet-2"<br>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | The project name. | `string` | `"conectathon"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The Subnet IDs to deploy resources | `list(string)` | <pre>[<br>  "subnet-1",<br>  "subnet-2"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created. | `string` | `"us-east-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | <pre>{<br>  "CreatedBy": "robaraneda@gmail.com",<br>  "Environment": "dev",<br>  "Project": "conectathon"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to deploy resources | `string` | `"vpc-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_keycloak_dns_name"></a> [alb\_keycloak\_dns\_name](#output\_alb\_keycloak\_dns\_name) | The DNS name of the ALB for Keycloak. |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | The name of the ECS cluster. |
| <a name="output_keycloak_admin_password"></a> [keycloak\_admin\_password](#output\_keycloak\_admin\_password) | The admin password for Keycloak. |
| <a name="output_keycloak_admin_user"></a> [keycloak\_admin\_user](#output\_keycloak\_admin\_user) | The admin user for Keycloak. |
| <a name="output_kong_db_host"></a> [kong\_db\_host](#output\_kong\_db\_host) | The host for the Kong database. |
| <a name="output_kong_db_password"></a> [kong\_db\_password](#output\_kong\_db\_password) | The password for the Kong database. |
| <a name="output_kong_db_username"></a> [kong\_db\_username](#output\_kong\_db\_username) | The username for the Kong database. |