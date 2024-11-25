
output "ec2_id" {
  value = aws_instance.ssm_host.id
}

output "ec2_eni_id" {
  value = aws_instance.ssm_host.primary_network_interface_id
}
