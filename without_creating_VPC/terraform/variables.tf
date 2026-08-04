variable "aws_region" {
  default = "us-east-1"
}

variable "os_choice" {
  description = "Choose OS: ubuntu, amazon, or rhel"
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(["ubuntu", "amazon", "rhel"], var.os_choice)
    error_message = "Must be one of: ubuntu, amazon, rhel."
  }
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "master_instance_type" {
  default = "t3.medium"
}

variable "worker_instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "The name of the AWS key pair (defined in tfvars or injected by deploy script)"
  type        = string
}

variable "private_key_path" {
  description = "The local path to the private key for Ansible interpolation"
  type        = string
}
