output "master_public_ip" {
  value = module.k8s_nodes.master_public_ip
}

output "worker_public_ips" {
  value = module.k8s_nodes.worker_public_ips
}
