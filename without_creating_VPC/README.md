# install_kubernetes_bare_metal_RHEL_Ubuntu_amazon_linux
---
Pre-requisites:
* If you don't have AWS CLI, Terraform and Ansible installed, then script will automatically install it and prompts for AWS CLI Credential configuration. If you have existing AWS CLI installation but not configured AWS CLI credentials, then please configure it. 
* Make sure you have git installed on your server to clone this Repo.
* If you want to customize the instance type, existing keypair name, number of worker nodes, OS type, then, go to the directory: `terraform/terraform.tfvars`
---

Installing Bare metal Kubernetes automatically on any OS of your choice: RHEL, Amazon Linux, Ubuntu. It uses Terraform to create infrastructure using your Default VPC and sets up EC2 instances using your specified SSH Keypair.
Then installs Kubernetes bare metal on the instance using Ansible and sets the master and worker node setup automatically.

---

If you're selecting existing keypair, then you can mention the public key name saved in AWS in `terraform.tfvars` file and you need to upload private key to the current directory. If you don't have the keypair, then the script will create a new one and save the private key in the current directory.

---
To setup Kubernetes in AWS, run:
```bash
bash deploy.sh
```

To destroy this infrastructure, run:
```bash
bash destroy.sh
```
