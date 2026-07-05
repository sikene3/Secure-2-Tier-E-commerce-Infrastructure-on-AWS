# ──────────────────────────────────────────────────────────────────────
# security.tf — Zero Trust 3-Tier Security Groups
# ──────────────────────────────────────────────────────────────────────

# ── ALB Security Group (Internet-Facing Tier) ─────────────────────────

resource "aws_security_group" "alb_sg" {
  name        = "Ecommerce-ALB-SG"
  description = "Security group for the public Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Ecommerce-ALB-SG"
    Tier        = "public"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Application Servers Security Group (Application Tier) ─────────────

resource "aws_security_group" "app_sg" {
  name        = "Ecommerce-App-SG"
  description = "Security group for the application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB only"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Ecommerce-App-SG"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Database Security Group (Data Tier) ───────────────────────────────

resource "aws_security_group" "db_sg" {
  name        = "Ecommerce-DB-SG"
  description = "Security group for the RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from application servers only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Ecommerce-DB-SG"
    Tier        = "database"
    Environment = "production"
    Project     = "ecommerce"
  }
}