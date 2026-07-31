#!/bin/bash


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
    echo "==> Terraform command is installed on $distro."
    terraform --version
    echo
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
    else
        echo "Unsupported Distribution - Only RHEL/Amazon Linux and Ubuntu/Debian supported."
        exit 1
    fi
    echo "==> Ansible command is installed on $distro."
    ansible --version
    echo
}

install_aws_cli() {
    echo "==> AWS CLI not found. Installing on $distro..."
    if [ "$distro" = "rhel" ] || [ "$distro" = "amzn" ]; then
        sudo dnf update -y > /dev/null 2>&1
        sudo yum install unzip -y > /dev/null 2>&1
    elif [ "$distro" = "ubuntu" ] || [  "$distro" = "debian" ]; then
        sudo apt-get update -y > /dev/null 2>&1
        sudo apt-get install unzip -y > /dev/null 2>&1
    else
        echo "Unsupported Distribution - Only RHEL/Amazon Linux and Ubuntu/Debian supported."
        exit 1
    fi
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null 2>&1
    unzip -q awscliv2.zip > /dev/null 2>&1
    sudo ./aws/install > /dev/null 2>&1
    rm -rf awscliv2.zip ./aws
    echo "==> AWS Cli installed on $distro."
    echo "Please configure your AWS credentials:"
    aws configure
    echo
    echo
}

# Run dependency checks
if ! command -v terraform &> /dev/null; then install_terraform; fi
if ! command -v ansible &> /dev/null; then install_ansible; fi
if ! command -v aws &> /dev/null; then install_aws_cli; fi

echo "==> Dependencies validated."
echo

# ==========================================
# 2. Execution
# ==========================================
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
