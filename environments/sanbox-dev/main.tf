
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = "sandbox-dev"
  region      = "us-east-1"
  
  # VPC Configuration
  vpc_cidr = "10.0.0.0/16"
  
  # Subnet Configuration
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
  
  # SSL Certificate ARN
  ssl_certificate_arn = "arn:aws:acm:us-east-1:527213286309:certificate/9b6d5d06-013a-4626-be5f-48d1d19df00a"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment            = local.environment
  vpc_cidr              = local.vpc_cidr
  public_subnet_cidrs   = local.public_subnet_cidrs
  private_subnet_cidrs  = local.private_subnet_cidrs
  availability_zones    = local.availability_zones
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security_groups"

  environment = local.environment
  vpc_id      = module.vpc.vpc_id
}

# Application Load Balancer Module
module "alb" {
  source = "../../modules/alb"

  environment           = local.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  ssl_certificate_arn  = local.ssl_certificate_arn
}

# ECS Module
module "ecs" {
  source = "../../modules/ecs"

  environment = local.environment
}
