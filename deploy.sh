#!/bin/bash
set -e

echo "==> Initializing and Applying Terraform..."
cd terraform
terraform init
terraform apply -auto-approve

echo "==> Waiting for EC2 instances to initialize SSH..."
sleep 30

echo "==> Running Ansible Playbook..."
cd ../ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini site.yml

echo "==> Deployment Complete. Access your master node via the generated k8s-ssh-key.pem!"