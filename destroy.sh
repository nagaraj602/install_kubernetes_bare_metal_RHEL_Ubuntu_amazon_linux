#!/bin/bash
set -e

echo "==> Destroying Terraform Infrastructure..."
cd terraform
terraform destroy -auto-approve
echo "==> Teardown Complete."