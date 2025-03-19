provider "aws" {
  region = var.region
}

# Terraform Backend Configuration for S3
terraform {
  backend "s3" {
    bucket         = "my-k8s-terraform-state" # Replace with your bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"              # Replace with your region
    dynamodb_table = "terraform-lock"         # Replace with your DynamoDB table name
  }
}

# VPC Module
module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr    = var.subnet_cidr
  az             = var.az
}

# Security Group Module
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# Kubernetes Nodes Module
module "k8s_nodes" {
  source            = "./modules/k8s_nodes"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_group.sg_id
  key_name          = var.key_name
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  worker_count      = var.worker_count
  ami               = var.ami
}
