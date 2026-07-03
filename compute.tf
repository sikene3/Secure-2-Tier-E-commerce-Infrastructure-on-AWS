# ──────────────────────────────────────────────────────────────────────
# compute.tf — Compute Layer & Application Load Balancer
# ──────────────────────────────────────────────────────────────────────

# ── AMI Data Source ───────────────────────────────────────────────────

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Application Load Balancer ─────────────────────────────────────────

resource "aws_lb" "ecommerce_alb" {
  name               = "ecommerce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name        = "Ecommerce-ALB"
    Tier        = "public"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── ALB Target Group ──────────────────────────────────────────────────

resource "aws_lb_target_group" "ecommerce_tg" {
  name     = "ecommerce-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path    = "/"
    port    = "80"
    matcher = "200"
  }

  tags = {
    Name        = "Ecommerce-Target-Group"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── ALB Listener ──────────────────────────────────────────────────────

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecommerce_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecommerce_tg.arn
  }
}

# ── Launch Template ───────────────────────────────────────────────────

resource "aws_launch_template" "ecommerce_lt" {
  name_prefix   = "ecommerce-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Ecommerce Production Environment - Highly Available" > /var/www/html/index.html
  EOF
  )

  tags = {
    Name        = "Ecommerce-Launch-Template"
    Tier        = "private"
    Environment = "production"
    Project     = "ecommerce"
  }
}

# ── Auto Scaling Group ────────────────────────────────────────────────

resource "aws_autoscaling_group" "ecommerce_asg" {
  name                = "ecommerce-asg"
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  target_group_arns = [aws_lb_target_group.ecommerce_tg.arn]

  launch_template {
    id      = aws_launch_template.ecommerce_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Ecommerce-App-Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "private"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "ecommerce"
    propagate_at_launch = true
  }
}