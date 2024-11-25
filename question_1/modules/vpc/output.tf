# Outputs
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "nlb_dns_name" {
  value = aws_lb.public_nlb.dns_name
}

output "nlb_id" {
  value = aws_lb.public_nlb.id
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "ssm_host_sg_id" {
  value = aws_security_group.ssm_host_sg.id
}

output "ssm_port_foward_sg_id" {
  value = aws_security_group.ssm_port_foward_sg.id
}
