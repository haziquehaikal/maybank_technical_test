
variable "rds_instance_name" {
  type = string
}

variable "rds_subnet_group_name" {
  type = string
}

variable "rds_sg_id" {
  type = list(string)
}
