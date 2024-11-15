# RDS Database Subnet Group Definition Module

Configuration in this directory creates an Amazon RDS instance.

## Usage

```hcl
module "subnet_group" {
  source      = "../../modules/rds_modules/rds_db_subnet_group"
  name        = "name"
  name_prefix = false
  subnet_ids  = ["subnet_id_1", "subnet_id_2"]
  description = "DB subnet group"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.7  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                    | Type     |
| ----------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |

## Inputs

| Name                                                               | Description                                                                                                  | Type           | Default          | Required |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ | -------------- | ---------------- | :------: |
| <a name="input_create"></a> [create](#input_create)                | Whether to create this resource or not?                                                                      | `bool`         | `true`           |    no    |
| <a name="input_description"></a> [description](#input_description) | The description of the DB subnet group                                                                       | `string`       | `"Subnet group"` |    no    |
| <a name="input_name"></a> [name](#input_name)                      | The name of the DB subnet group                                                                              | `string`       | `""`             |    no    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Determines whether to use `name` as is or create a unique name beginning with `name` as the specified prefix | `bool`         | `true`           |    no    |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)    | A list of VPC subnet IDs                                                                                     | `list(string)` | `[]`             |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                      | A mapping of tags to assign to the resource                                                                  | `map(string)`  | `{}`             |    no    |

## Outputs

| Name                                                                                         | Description                    |
| -------------------------------------------------------------------------------------------- | ------------------------------ |
| <a name="output_db_subnet_group_arn"></a> [db_subnet_group_arn](#output_db_subnet_group_arn) | The ARN of the db subnet group |
| <a name="output_db_subnet_group_id"></a> [db_subnet_group_id](#output_db_subnet_group_id)    | The db subnet group name       |

<!-- END_TF_DOCS -->
