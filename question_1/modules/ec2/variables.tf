variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = list(string)
}

variable "security_group_id" {
  type = list(string)
}

variable "ssm_sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "image_id" {
  type    = string
  default = "ami-0474411b350de35fb"

}
