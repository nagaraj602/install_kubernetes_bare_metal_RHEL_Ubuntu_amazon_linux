# install_kubernetes_bare_metal_RHEL_Ubuntu_amazon_linux
Installing Bare metal Kubernetes automatically on any OS of your choice: RHEL, Amazon Linux, Ubuntu

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

