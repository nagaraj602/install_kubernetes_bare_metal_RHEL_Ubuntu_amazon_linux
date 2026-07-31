# Dynamic AMI Lookups
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }
}

locals {
  selected_ami = var.os_choice == "ubuntu" ? data.aws_ami.ubuntu.id : (var.os_choice == "amazon" ? data.aws_ami.amazon_linux.id : data.aws_ami.rhel.id)
  ssh_user     = var.os_choice == "ubuntu" ? "ubuntu" : "ec2-user"
}

# SSH Key Generation (Conditional)
resource "tls_private_key" "k8s_key" {
  count     = var.create_new_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count           = var.create_new_key ? 1 : 0
  key_name_prefix = "k8s-ssh-key-" # Prefix prevents "already exists" errors on recreation
  public_key      = tls_private_key.k8s_key[0].public_key_openssh
}

resource "local_file" "private_key" {
  count           = var.create_new_key ? 1 : 0
  content         = tls_private_key.k8s_key[0].private_key_pem
  filename        = "${path.module}/${var.private_key_path}"
  file_permission = "0400"
}

# Master Node
resource "aws_instance" "master" {
  ami                    = local.selected_ami
  instance_type          = var.master_instance_type
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.create_new_key ? aws_key_pair.generated_key[0].key_name : var.existing_key_name

  tags = { Name = "k8s-master", Role = "master" }
}

# Worker Nodes
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = local.selected_ami
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.create_new_key ? aws_key_pair.generated_key[0].key_name : var.existing_key_name

  tags = { Name = "k8s-worker-${count.index + 1}", Role = "worker" }
}

# Dynamic Ansible Inventory Generation
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    master_ip        = aws_instance.master.public_ip
    worker_ips       = aws_instance.worker[*].public_ip
    ssh_user         = local.ssh_user
    private_key_path = var.private_key_path
  })
  filename = "${path.module}/../ansible/inventory.ini"
}
