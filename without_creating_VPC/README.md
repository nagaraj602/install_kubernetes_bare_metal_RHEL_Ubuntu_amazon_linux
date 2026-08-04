# install_kubernetes_bare_metal_RHEL_Ubuntu_amazon_linux
---
Installing Bare metal Kubernetes automatically on any OS of your choice: RHEL, Amazon Linux, Ubuntu. It uses Terraform to create infrastructure using your Default VPC and sets up EC2 instances using your specified SSH Keypair.
Then installs Kubernetes bare metal on the instance using Ansible and sets the master and worker node setup automatically.
---
If you want to change the OS to be selected during Kubernetes installation, you can go to `terraform/terraform.tfvars` and change the values to "ubuntu" or "rhel" or "amazon".

You can also change the Instance type, the number of worker nodes, and the name of the SSH key you want to use.

---
To setup Kubernetes in AWS, run:
```bash
bash deploy.sh
```

To destroy this infrastructure, run:
```bash
bash destroy.sh
```
