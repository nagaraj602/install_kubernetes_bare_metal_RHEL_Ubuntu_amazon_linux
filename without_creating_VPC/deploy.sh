#!/bin/bash
set -e

# ==========================================
# 1. Dependency Checks & Installation
# ==========================================
distro=$(grep "^ID=" /etc/os-release | cut -d "=" -f2 | tr -d '"')

install_terraform() {
    echo "==> Terraform not found. Installing on $distro..."
    if [ "$distro" = "rhel" ]; then
        sudo dnf update -y > /dev/null 2>&1
        sudo yum install -y yum-utils > /dev/null 2>&1
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo > /dev/null 2>&1
        sudo yum -y install terraform > /dev/null 2>&1
    elif [ "$distro" = "amzn" ]; then
        sudo yum install -y yum-utils shadow-utils > /dev/null 2>&1
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo > /dev/null 2>&1
        sudo yum install terraform -y > /dev/null 2>&1
    elif [ "$distro" = "ubuntu" ] || [  "$distro" = "debian" ]; then
        sudo apt-get update -y > /dev/null 2>&1
        wget -qO - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
        sudo apt update -y > /dev/null 2>&1
        sudo apt install terraform -y > /dev/null 2>&1
    else
        echo "Unsupported Distribution - Only RHEL/Amazon Linux and Ubuntu/Debian supported."
        exit 1
    fi
    echo "==> Terraform installed successfully."
}

install_ansible() {
    echo "==> Ansible not found. Installing on $distro..."
    if [ "$distro" = "rhel" ]; then
        sudo dnf update -y > /dev/null 2>&1
        sudo dnf upgrade -y > /dev/null 2>&1
        sudo dnf install -y python3 python3-pip > /dev/null 2>&1
        sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm > /dev/null 2>&1
        sudo dnf install -y ansible > /dev/null 2>&1
        ansible-galaxy collection install amazon.aws > /dev/null 2>&1
    elif [ "$distro" = "amzn" ]; then
        sudo dnf update -y > /dev/null 2>&1
        sudo dnf upgrade -y > /dev/null 2>&1
        sudo dnf install -y python3 python3-pip > /dev/null 2>&1
        sudo dnf install ansible -y > /dev/null 2>&1
        ansible-galaxy collection install amazon.aws > /dev/null 2>&1
    elif [ "$distro" = "ubuntu" ] || [ "$distro" = "debian" ]; then
        sudo apt update > /dev/null 2>&1
        sudo apt upgrade -y > /dev/null 2>&1
        sudo apt install -y python3 python3-pip ansible > /dev/null 2>&1
        python3 -m pip install --user boto3 botocore > /dev/null 2>&1
        ansible-galaxy collection install amazon.aws > /dev/null 2>&1
    fi
    echo "==> Ansible installed successfully."
}

install_aws_cli() {
    echo "==> AWS CLI not found. Installing on $distro..."
    if [ "$distro" = "rhel" ] || [ "$distro" = "amzn" ]; then
        sudo dnf update -y > /dev/null 2>&1
        sudo yum install unzip -y > /dev/null 2>&1
    elif [ "$distro" = "ubuntu" ] || [  "$distro" = "debian" ]; then
        sudo apt-get update -y > /dev/null 2>&1
        sudo apt-get install unzip -y > /dev/null 2>&1
    fi
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null 2>&1
    unzip -q awscliv2.zip > /dev/null 2>&1
    sudo ./aws/install > /dev/null 2>&1
    rm -rf awscliv2.zip ./aws
    echo "==> AWS CLI installed successfully."
    echo "Please configure your AWS credentials to proceed:"
    aws configure
    echo
}

if ! command -v terraform &> /dev/null; then install_terraform; fi
if ! command -v ansible &> /dev/null; then install_ansible; fi
if ! command -v aws &> /dev/null; then install_aws_cli; fi

echo "==> Core dependencies validated."
echo

# ==========================================
# 2. Dynamic SSH Key Management
# ==========================================
TFVARS_FILE="terraform/terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
    EXPECTED_KEY_NAME=$(grep -E '^\s*key_name\s*=' "$TFVARS_FILE" | awk -F'"' '{print $2}')
fi

EXPECTED_KEY_NAME=${EXPECTED_KEY_NAME:-"nagaraj"}
EXPECTED_PEM="${EXPECTED_KEY_NAME}.pem"

handle_ssh_key() {
    if [ -f "$EXPECTED_PEM" ]; then
        echo "==> Found $EXPECTED_PEM in $(pwd)."
        chmod 400 "$EXPECTED_PEM"
        export TF_VAR_private_key_path="../$EXPECTED_PEM"
        return 0
    fi

    while true; do
        read -p "==> $EXPECTED_PEM not found. Have you placed the $EXPECTED_PEM file in this directory $(pwd)? (yes/no): " user_placed
        if [[ "$user_placed" =~ ^[Yy]es$ ]]; then
            if [ -f "$EXPECTED_PEM" ]; then
                echo "==> Verified $EXPECTED_PEM is now present."
                chmod 400 "$EXPECTED_PEM"
                export TF_VAR_private_key_path="../$EXPECTED_PEM"
                break
            else
                echo "==> Error: $EXPECTED_PEM is still not found. Please try again or type 'no' on the next prompt."
            fi
        elif [[ "$user_placed" =~ ^[Nn]o$ ]]; then
            read -p "==> Do you want to create a new keypair and use that to create all infra? (yes/no): " create_new
            if [[ "$create_new" =~ ^[Yy]es$ ]]; then
                KEY_NAME="k8s-dynamic-key-$(date +%s)"
                KEY_FILE="${KEY_NAME}.pem"
                
                echo "==> Generating a new RSA SSH key pair: $KEY_FILE..."
                ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -N "" -q
                chmod 400 "$KEY_FILE"
                
                echo "==> Importing the new key pair to AWS as '$KEY_NAME'..."
                aws ec2 import-key-pair --key-name "$KEY_NAME" --public-key-material "fileb://${KEY_FILE}.pub" > /dev/null
                
                export TF_VAR_key_name="$KEY_NAME"
                export TF_VAR_private_key_path="../${KEY_FILE}"
                
                echo "$KEY_NAME" > .dynamic_key_name
                break
            else
                echo "==> Exiting. A valid SSH key is strictly required to proceed with Ansible provisioning."
                exit 1
            fi
        else
            echo "==> Invalid input. Please type 'yes' or 'no'."
        fi
    done
}

handle_ssh_key

# ==========================================
# 3. Execution
# ==========================================
echo "==> Initializing and Applying Terraform..."
cd terraform
terraform init > /dev/null 2>&1
terraform apply -auto-approve

echo "==> Waiting 30 seconds for EC2 instances to fully boot and expose SSH..."
sleep 30

echo "==> Running Ansible Playbook..."
cd ../ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini site.yml

echo "==> Deployment Complete. Access your cluster nodes utilizing the configured key!"
