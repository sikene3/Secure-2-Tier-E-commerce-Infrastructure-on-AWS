# ──────────────────────────────────────────────────────────────────────
# routing.tf — Highly Available Routing & NAT Configuration
# ──────────────────────────────────────────────────────────────────────

# ── Elastic IPs for NAT Gateways ──────────────────────────────────────

resource "aws_eip" "nat_a" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "Ecommerce-NAT-EIP-us-east-1a"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "Ecommerce-NAT-EIP-us-east-1b"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── NAT Gateways (one per AZ for high availability) ───────────────────

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "Ecommerce-NAT-Gateway-us-east-1a"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "Ecommerce-NAT-Gateway-us-east-1b"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Public Route Table ────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "Ecommerce-Public-RouteTable"
    Tier        = "public"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Public Route Table Associations ───────────────────────────────────

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ── Private Route Table A (us-east-1a) ────────────────────────────────

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name        = "Ecommerce-Private-RouteTable-us-east-1a"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# ── Private Route Table B (us-east-1b) ────────────────────────────────

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = {
    Name        = "Ecommerce-Private-RouteTable-us-east-1b"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}