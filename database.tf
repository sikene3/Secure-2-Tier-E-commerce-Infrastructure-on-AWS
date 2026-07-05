# ──────────────────────────────────────────────────────────────────────
# database.tf — RDS MySQL Database (Private Tier)
# ──────────────────────────────────────────────────────────────────────

# ── DB Subnet Group ───────────────────────────────────────────────────

resource "aws_db_subnet_group" "ecommerce_db_subnet_group" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name        = "Ecommerce-DB-Subnet-Group"
    Tier        = "database"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── RDS MySQL Instance ────────────────────────────────────────────────

resource "aws_db_instance" "ecommerce_db" {
  identifier     = "ecommerce-production-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "ecommercedb"
  username = "admin"
  password = "SuperSecretPassword123!"

  db_subnet_group_name   = aws_db_subnet_group.ecommerce_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 0

  tags = {
    Name        = "Ecommerce-Production-DB"
    Tier        = "database"
    Environment = "production"
    Project     = "ecommerce"
  }
}