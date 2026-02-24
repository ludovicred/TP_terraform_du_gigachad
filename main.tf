resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.nom_du_vpc
  }
}

# ─── SUBNETS ────────────────────────────────────────────────────────────────

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sub_pub1
  availability_zone = "us-east-1a"

  tags = { Name = "subnet-pub1" }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sub_pub2
  availability_zone = "us-east-1b"

  tags = { Name = "subnet-pub2" }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sub_priv1
  availability_zone = "us-east-1a"

  tags = { Name = "subnet-priv1" }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sub_priv2
  availability_zone = "us-east-1b"

  tags = { Name = "subnet-priv2" }
}

# ─── INTERNET GATEWAY ────────────────────────────────────────────────────────

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "igw-main" }
}

# ─── NAT GATEWAY (placée dans pub1, sert les privés) ─────────────────────────

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = { Name = "natgw-main" }
}

# ─── TABLE RPB (publique) ────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = { Name = "table-rpb" }
}

resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# ─── TABLE RPV (privée) ──────────────────────────────────────────────────────

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = { Name = "table-rpv" }
}

resource "aws_route_table_association" "priv1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "priv2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# ─── SECURITY GROUPS ─────────────────────────────────────────────────────────

resource "aws_security_group" "sg_lb" {
  name   = "sgload-balancer"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-lb" }
}

resource "aws_security_group" "sg_web" {
  name   = "sgweb-servers"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-web" }
}

# ─── KEY PAIR SSH ─────────────────────────────────────────────────────────────

resource "aws_key_pair" "ssh_key" {
  key_name   = "web-key"
  public_key = file("sshkey/pubkeymoi.pub")
}

# ─── EC2 SERVEURS WEB ─────────────────────────────────────────────────────────

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu officiel)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

locals {
  user_data_web1 = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Serveur Web 1</h1>" > /var/www/html/index.html
    EOF
  )

  user_data_web2 = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Serveur Web 2</h1>" > /var/www/html/index.html
    EOF
  )
}

resource "aws_instance" "web1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data_base64       = local.user_data_web1

  lifecycle {
    replace_triggered_by = [terraform_data.web1_userdata]
  }

  tags = { Name = "srv-web1" }
}

resource "terraform_data" "web1_userdata" {
  input = local.user_data_web1
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data_base64       = local.user_data_web2

  lifecycle {
    replace_triggered_by = [terraform_data.web2_userdata]
  }

  tags = { Name = "srv-web2" }
}

resource "terraform_data" "web2_userdata" {
  input = local.user_data_web2
}

# ─── APPLICATION LOAD BALANCER ───────────────────────────────────────────────

resource "aws_lb" "alb" {
  name               = "alb-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = { Name = "alb-main" }
}

resource "aws_lb_target_group" "tg_web" {
  name     = "tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tg_web1" {
  target_group_arn = aws_lb_target_group.tg_web.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_web2" {
  target_group_arn = aws_lb_target_group.tg_web.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web.arn
  }
}
