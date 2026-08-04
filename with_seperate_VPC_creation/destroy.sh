#!/bin/bash
set -e

echo "==> Destroying Terraform Infrastructure..."
cd terraform
terraform destroy -auto-approve
echo "==> Kubernetes Infra Destruction Complete."
