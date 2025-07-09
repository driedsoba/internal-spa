output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.spa_alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.spa_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.spa_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.spa_alb.zone_id
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.lb_target_group.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.lb_target_group.arn
}
