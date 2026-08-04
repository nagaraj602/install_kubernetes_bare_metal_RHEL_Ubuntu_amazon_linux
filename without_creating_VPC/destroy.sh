#!/bin/bash
set -e

echo "==> Destroying Terraform Infrastructure..."
cd terraform
terraform destroy -auto-approve
cd ..

if [ -f ".dynamic_key_name" ]; then
    DYNAMIC_KEY=$(cat .dynamic_key_name)
    echo "==> Cleaning up dynamically generated AWS key pair: $DYNAMIC_KEY..."
    aws ec2 delete-key-pair --key-name "$DYNAMIC_KEY" > /dev/null 2>&1 || true
    rm -f .dynamic_key_name
    rm -f ${DYNAMIC_KEY}.pem ${DYNAMIC_KEY}.pem.pub
fi

echo "==> Kubernetes Infra Destruction Complete."
