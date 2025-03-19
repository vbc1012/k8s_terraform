variable "subnet_id" {
  description = "Subnet ID for the instances"
}

variable "security_group_id" {
  description = "Security Group ID for the instances"
}

variable "key_name" {
  description = "SSH key pair name"
}

variable "master_instance_type" {
  description = "Instance type for the master node"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
}

variable "worker_count" {
  description = "Number of worker nodes"
}

variable "ami" {
  description = "AMI ID for the instances"
}
