output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "worker_public_ips" {
  value = aws_instance.worker[*].public_ip
}

output "ssh_command_master" {
  value = "ssh -i ../k8s-ssh-key.pem ${local.ssh_user}@${aws_instance.master.public_ip}"
}