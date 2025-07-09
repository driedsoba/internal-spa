# ALB
resource "aws_lb" "spa_alb" {
  name               = "spa-internal-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name      = "${var.project_name}-internal-alb"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# Target Group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "s3-spa-target-public"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_group_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = {
    Name      = "${var.project_name}-spa-target-public"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}
