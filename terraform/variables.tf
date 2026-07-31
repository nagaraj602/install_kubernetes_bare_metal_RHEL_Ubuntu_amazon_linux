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

# New variables for Key Pair Logic
variable "create_new_key" {
  description = "Boolean to decide whether to create a new key pair"
  type        = bool
  default     = true
}

variable "existing_key_name" {
  description = "Name of the existing AWS key pair"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to the private key used by Ansible"
  type        = string
  default     = "../k8s-generated-key.pem"
}
