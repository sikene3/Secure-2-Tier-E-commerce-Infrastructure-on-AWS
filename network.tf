# ──────────────────────────────────────────────────────────────────────
# network.tf — 2-Tier E-Commerce Networking Infrastructure
# ──────────────────────────────────────────────────────────────────────

# ── VPC ───────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "Ecommerce-Production-VPC"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Internet Gateway ──────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Ecommerce-Production-IGW"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Public Subnets ────────────────────────────────────────────────────

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "Ecommerce-Public-Subnet-us-east-1a"
    Tier        = "public"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "Ecommerce-Public-Subnet-us-east-1b"
    Tier        = "public"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Private Subnets ───────────────────────────────────────────────────

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "Ecommerce-Private-Subnet-us-east-1a"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name        = "Ecommerce-Private-Subnet-us-east-1b"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}