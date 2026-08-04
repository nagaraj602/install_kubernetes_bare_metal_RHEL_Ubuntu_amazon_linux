# Install Bare Metal Kubernetes on RHEL/Ubuntu/Amazon Linux Distribution
---
Installing Bare metal Kubernetes automatically on any OS of your choice: RHEL, Amazon Linux, Ubuntu. It uses terraform to create infrastructure: VPC, subnet, igw, Security Group, route table, public and private Keypair and ec2.
Then installs Kubernetes bare metal on the instance using Ansible and sets the master and worker node setup automatically.

---
Pre-requisites:
* If you don't have AWS CLI, Terraform and Ansible installed, then script will automatically install it and prompts for AWS CLI Credential configuration. If you have existing AWS CLI installation but not configured AWS CLI credentials, then please configure it. 
* Make sure you have git installed on your server to clone this Repo.
* If you want to customize the instance type, number of worker nodes, OS type, then, go to: `terraform/terraform.tfvars`
---


To setup Kubernetes in AWS, you run:
```
bash deploy.sh
```

To Destroy these infra, you can run:
```
bash destroy.sh
```

