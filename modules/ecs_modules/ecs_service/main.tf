locals {
  load_balancer_security_group_name = "${var.load_balancer.name}-load-balancer"
  ecs_service_security_group_name   = "${var.name}-ecs-service"
}

resource "aws_security_group" "load_balancer" {

  name   = local.load_balancer_security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = local.load_balancer_security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {

  count = var.load_balancer.listeners.http.enabled ? 1 : 0

  security_group_id = aws_security_group.load_balancer.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {

  count = var.load_balancer.listeners.https.enabled ? 1 : 0

  security_group_id = aws_security_group.load_balancer.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "load_balancer" {
  security_group_id = aws_security_group.load_balancer.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_lb" "this" {
  internal           = var.load_balancer.internal
  name               = var.load_balancer.name
  load_balancer_type = var.load_balancer.type
  subnets            = var.load_balancer.subnet_ids
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Name = var.load_balancer.name
  }
}



resource "aws_security_group" "ecs_service" {
  name   = local.ecs_service_security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = local.ecs_service_security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_service" {

  security_group_id = aws_security_group.ecs_service.id

  from_port                    = var.load_balancer.target_group.port
  ip_protocol                  = "tcp"
  to_port                      = var.load_balancer.target_group.port
  referenced_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_service" {
  security_group_id = aws_security_group.ecs_service.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

}


resource "aws_lb_target_group" "this" {
  name        = var.load_balancer.target_group.name
  port        = var.load_balancer.target_group.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = var.load_balancer.target_group.health_check.path
    port     = var.load_balancer.target_group.health_check.port
    interval = 60
  }

  tags = {
    Name = var.load_balancer.name
  }
}

resource "aws_lb_listener" "https" {
  count = var.load_balancer.listeners.https.enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.load_balancer.listeners.https.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, {
    Name = var.load_balancer.name
  })
}

resource "aws_lb_listener" "http" {
  count = var.load_balancer.listeners.http.enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = var.load_balancer.listeners.http.action_type
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, {
    Name = var.load_balancer.name
  })
}

resource "aws_ecs_service" "this" {
  name                              = var.name
  cluster                           = var.cluster_id
  task_definition                   = var.task_definition_arn
  launch_type                       = var.launch_type //default is FARGATE
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.health_check_grace_period_seconds


  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.load_balancer.target_group.name
    container_port   = var.load_balancer.target_group.port
  }

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.ecs_service.id]
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}


