locals {
  load_balancer_security_group_name = "${var.name}-load-balancer"
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
  #for_each = { for lb in var.load_balancers : lb.name => lb if lb.listeners.http.enabled }

  security_group_id = aws_security_group.load_balancer.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  #for_each = { for lb in var.load_balancers : lb.name => lb if lb.listeners.https.enabled }

  security_group_id = aws_security_group.load_balancer.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.load_balancer.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_lb" "this" {

  for_each = { for lb in var.load_balancers : lb.name => lb }

  internal           = each.value.internal
  name               = each.value.name
  load_balancer_type = each.value.type
  subnets            = each.value.subnet_ids
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Name = each.value.name
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

  for_each = { for lb in var.load_balancers : lb.name => lb }

  security_group_id = aws_security_group.ecs_service.id

  from_port                    = each.value.target_group.port
  ip_protocol                  = "tcp"
  to_port                      = each.value.target_group.port
  referenced_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_service" {
  security_group_id = aws_security_group.ecs_service.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

}


resource "aws_lb_target_group" "this" {
  for_each = { for lb in var.load_balancers : lb.name => lb }

  name        = each.value.target_group.name
  port        = each.value.target_group.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = each.value.target_group.health_check.path
    port     = each.value.target_group.health_check.port
    interval = 60
  }

  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_listener" "https" {
  for_each = { for lb in var.load_balancers : lb.name => lb if lb.listeners.https.enabled }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = each.value.listeners.https.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

resource "aws_lb_listener" "http" {
  for_each = { for lb in var.load_balancers : lb.name => lb if lb.listeners.http.enabled }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = each.value.listeners.http.action_type
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

resource "aws_ecs_service" "this" {
  name                              = var.name
  cluster                           = var.cluster_id
  task_definition                   = var.task_definition_arn
  launch_type                       = var.launch_type //default is FARGATE
  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.health_check_grace_period_seconds


  dynamic "load_balancer" {
    for_each = { for lb in var.load_balancers : lb.name => lb.target_group }
    content {
      target_group_arn = aws_lb_target_group.this[load_balancer.key].arn
      container_name   = load_balancer.value.container
      container_port   = load_balancer.value.port
    }
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


