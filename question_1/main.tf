provider "aws" {
  region = "ap-southeast-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

module "vpc" {
  source                     = "./modules/vpc"
  main_vpc_cidr              = "172.10.0.0/16"
  main_vpc_name              = "main-vpc"
  public_subnet_cidr_blocks  = ["172.10.1.0/24", "172.10.2.0/24"]
  private_subnet_cidr_blocks = ["172.10.3.0/24", "172.10.4.0/24"]
  local_cidr_block           = "192.168.0.0/16"
  all_access_cidr_block      = "0.0.0.0/0"

}

module "ec2" {
  source            = "./modules/ec2"
  public_subnet_id  = module.vpc.public_subnet_id[0]
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = [module.vpc.ssm_host_sg_id]
  ssm_sg_id         = module.vpc.ssm_port_foward_sg_id

}

module "rds" {
  source                = "./modules/rds"
  rds_instance_name     = "rds-master"
  rds_subnet_group_name = module.vpc.rds_subnet_group_name
  rds_sg_id             = [module.vpc.rds_sg_id]
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "maybank_bucket"
}

module "cloudfront" {
  source                      = "./modules/cloudfront"
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  bucket_id                   = module.s3.bucket_id
  nlb_dns_name                = module.vpc.nlb_dns_name
  nlb_id                      = module.vpc.nlb_id
}






