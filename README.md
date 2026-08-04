# Install Bare Metal Kubernetes on RHEL/Ubuntu/amazon Linux distribution
---
Pre-requisites:
* If you have existing AWS CLI installation but not configured AWS CLI credentials, please configure it.
* Make sure you have git installed on your server to clone this Repo.
* If you want to customize the instance type, existing keypair, number of worker nodes, OS type, then, go to the directory: terraform/terraform.tfvars

---
Installing Bare metal Kubernetes automatically on any OS of your choice: RHEL, Amazon Linux, Ubuntu. There are two folders, 
1) with_seperate_VPC_creation  
2) without_creating_VPC

The first option will create infrastructure: VPC, subnet, igw, Security Group, route table, public and private Keypair and ec2.
Then installs Kubernetes bare metal on the instance using Ansible and sets the master and worker node setup automatically.

The second option will not create VPC, subnet, igw, route table, and ec2. It creates Security Group with All traffic allowed. This will also give option to select the existing keypair or else, script will create a new one. It will only install Kubernetes bare metal on the instance using Ansible and sets the master and worker node setup automatically.
—--
#### Note: 
In the second option, terraform will use default VPC and if you already have the keypair, then you can mention the public key name saved in AWS in terraform.tfvars file and you need to upload private key to the current directory. If you don't have the keypair, then script will create a new one and save the private key in the current directory. 
If the keypair was created by script, then it gets deleted automatically when you run destroy.sh script. If you have existing keypair, then it will not delete the keypair when you run destroy.sh script.

---
If you want to change the OS to be selected during Kubernetes installation, you can go to terraform/terraform.tfvars and change the values to "ubuntu" or "rhel" or "amazon"

Also you can change the Instance type and number of worker node you want to create.

---
To setup Kubernetes in AWS, you run:
```
bash deploy.sh
```

To Destroy these infra, you can run:
```
bash destroy.sh
```

