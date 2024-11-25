variable "main_vpc_cidr" {
  type = string
}

variable "main_vpc_name" {
  type = string
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "local_cidr_block" {
  type = string
}

variable "all_access_cidr_block" {
  type = string
}

