variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "az" {
  description = "Availability Zone"
  default     = "us-east-1a"
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "MyEC3" # Replace with your key name
}

variable "master_instance_type" {
  description = "Instance type for the master node"
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  default     = "t2.micro"
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 1
}

variable "ami" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  default     = "ami-0e86e20dae9224db8" # us-east-1, update for your region
}
