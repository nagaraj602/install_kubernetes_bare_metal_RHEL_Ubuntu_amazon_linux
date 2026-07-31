#!/bin/bash


# Interactive Keypair Selection
read -p "Do you want to use an existing AWS key pair? (y/n): " USE_EXISTING
if [[ "$USE_EXISTING" =~ ^[Yy]$ ]]; then
    read -p "Enter the name of the existing AWS Key Pair stored in AWS: " AWS_KEY_NAME
    read -p "Enter the absolute path to your local private key (.pem) for this key pair: " PRIVATE_KEY_PATH
    CREATE_NEW="false"
else
    echo "==> A new key pair will be generated automatically."
    AWS_KEY_NAME=""
    PRIVATE_KEY_PATH="../k8s-generated-key.pem"
    CREATE_NEW="true"
fi

echo "==> Initializing and Applying Terraform..."
cd terraform
terraform init
terraform apply -auto-approve \
  -var="create_new_key=$CREATE_NEW" \
  -var="existing_key_name=$AWS_KEY_NAME" \
  -var="private_key_path=$PRIVATE_KEY_PATH"

echo "==> Waiting for EC2 instances to initialize SSH..."
sleep 30

echo "==> Running Ansible Playbook..."
cd ../ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini site.yml

echo "==> Deployment Complete!"
if [ "$CREATE_NEW" = "true" ]; then
    echo "Access your master node using the newly generated key: k8s-generated-key.pem"
else
    echo "Access your master node using your existing key: $PRIVATE_KEY_PATH"
fi
