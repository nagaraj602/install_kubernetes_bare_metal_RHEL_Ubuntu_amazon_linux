output "kubernetes_nodes" {
  description = "Topology of the provisioned nodes and public IPs"
  value = merge(
    { "k8s-master" = aws_instance.master.public_ip },
    { for idx, worker in aws_instance.worker : "k8s-worker-${idx + 1}" => worker.public_ip }
  )
}

output "ssh_command_master" {
  value = "ssh -i ${var.private_key_path} ${local.ssh_user}@${aws_instance.master.public_ip}"
}
