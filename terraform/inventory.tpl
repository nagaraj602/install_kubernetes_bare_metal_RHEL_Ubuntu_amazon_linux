[master]
${master_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${private_key_path}

[worker]
%{ for ip in worker_ips ~}
${ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${private_key_path}
%{ endfor ~}
