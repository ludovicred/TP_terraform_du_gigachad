# ─── VPC ─────────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

# ─── SUBNETS ─────────────────────────────────────────────────────────────────

output "subnet_public1_id" {
  description = "ID du subnet public 1 (us-east-1a)"
  value       = aws_subnet.public1.id
}

output "subnet_public2_id" {
  description = "ID du subnet public 2 (us-east-1b)"
  value       = aws_subnet.public2.id
}

output "subnet_private1_id" {
  description = "ID du subnet privé 1 (us-east-1a)"
  value       = aws_subnet.private1.id
}

output "subnet_private2_id" {
  description = "ID du subnet privé 2 (us-east-1b)"
  value       = aws_subnet.private2.id
}

# ─── GATEWAYS ────────────────────────────────────────────────────────────────

output "igw_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "ID de la NAT Gateway"
  value       = aws_nat_gateway.natgw.id
}

output "nat_eip" {
  description = "IP publique de la NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# ─── LOAD BALANCER ───────────────────────────────────────────────────────────

output "alb_dns_name" {
  description = "DNS du Load Balancer (URL pour accéder au site)"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.alb.arn
}

# ─── EC2 ─────────────────────────────────────────────────────────────────────

output "web1_private_ip" {
  description = "IP privée du serveur web 1"
  value       = aws_instance.web1.private_ip
}

output "web2_private_ip" {
  description = "IP privée du serveur web 2"
  value       = aws_instance.web2.private_ip
}
