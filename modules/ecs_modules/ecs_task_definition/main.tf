data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_execution_role ? 1 : 0
  name  = "ECSTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

/*
resource "aws_iam_policy" "ecs_task_execution_role_policy" {
  name        = "ECSTaskExecutionRolePolicy"
  description = "Policy for ECS Task Execution Role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "ecr:GetAuthorizationToken",
       "ecr:BatchCheckLayerAvailability",
       "ecr:GetDownloadUrlForLayer",
       "ecr:GetRepositoryPolicy",
       "ecr:ListImages",
       "ecr:DescribeRepositories",
       "ecr:DescribeImages",
       "ecr:BatchGetImage",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "kms:*"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}
*/

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {

  count      = var.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/*
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment_custom" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
}

*/

resource "aws_iam_role" "ecs_task_role" {
  count = var.create_task_role ? 1 : 0

  name               = "ECSTaskRole"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ecs-tasks.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment_ecs_role" {
  count = var.ecs_role_policy_arn_attachment_enabled ? 1 : 0

  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = var.ecs_role_policy_arn_attachment
}

locals {
  ports = [for port in var.container_ports : port]
}


resource "aws_ecs_task_definition" "this" {

  count  = var.create_task_definition ? 1 : 0
  family = var.family

  container_definitions = jsonencode([
    {
      name      = "${var.container_name}",
      image     = "${var.container_image}",
      essential = true
      portMappings = [
        for port in var.container_ports : {
          protocol      = "tcp"
          containerPort = port
          hostPort      = port
          appProtocol   = "http"
        }
      ],
      command     = var.command,
      environment = var.environment,
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.log_group_name}"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  skip_destroy             = true
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  memory                   = var.memory
  cpu                      = var.cpu

  execution_role_arn = var.create_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ECSTaskExecutionRole" //"arn:aws:iam::654654309886:role/ECSTaskExecutionRole"
  task_role_arn      = var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ECSTaskRole"                         //"arn:aws:iam::654654309886:role/ECSTaskRole"


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = merge(var.tags, {
    Name = var.family
  })
}