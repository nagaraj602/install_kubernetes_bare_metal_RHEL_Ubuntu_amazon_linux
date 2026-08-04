[master]
${master_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=../k8s-ssh-key.pem

[worker]
%{ for ip in worker_ips ~}
${ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=../k8s-ssh-key.pem
%{ endfor ~}