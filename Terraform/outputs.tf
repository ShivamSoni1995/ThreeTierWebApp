output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.three_tier_vpc.id
}

output "subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}
