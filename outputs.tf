# ──────────────────────────────────────────────────────────────────────
# outputs.tf — Infrastructure Connection Endpoints
# ──────────────────────────────────────────────────────────────────────

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer to access the web application"
  value       = aws_lb.ecommerce_alb.dns_name
}

output "rds_endpoint" {
  description = "The connection endpoint for the private RDS database"
  value       = aws_db_instance.ecommerce_db.endpoint
}