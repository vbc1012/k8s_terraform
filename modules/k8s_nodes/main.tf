locals {
  master_user_data = <<EOF
#!/bin/bash
set -eux

# Update & Install Dependencies
apt update && apt upgrade -y
apt install -y docker.io
systemctl start docker
systemctl enable docker
apt install -y curl apt-transport-https ca-certificates

# Install Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet kubeadm kubectl
systemctl enable kubelet

# Disable Swap (Required for Kubernetes)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Initialize Kubernetes Cluster with Correct CIDR for Calico
kubeadm init --pod-network-cidr=192.168.0.0/16 > /tmp/kubeadm_init.log

# Setup kubectl for Ubuntu User
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Apply Calico Network Plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Restart kubelet to ensure networking is ready
systemctl restart kubelet

echo "Master setup complete. Run 'kubectl get nodes' to verify."
EOF
}

locals {
  worker_user_data = <<EOF
#!/bin/bash
set -e

# Update system packages
apt update && apt upgrade -y

# Install dependencies
apt install -y apt-transport-https ca-certificates curl gpg software-properties-common

# Load required kernel modules
cat <<EOF1 | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF1

modprobe overlay
modprobe br_netfilter

# Configure sysctl settings
cat <<EOF2 | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF2

sysctl --system

# Install containerd
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Set containerd to use systemd
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart services
systemctl restart containerd
systemctl enable containerd

# Install Kubernetes tools
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet kubeadm kubectl
systemctl enable kubelet

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "Worker setup complete. Obtain the kubeadm join command from the master and run it manually."
EOF
}

resource "aws_instance" "k8s_master" {
  ami                    = var.ami
  instance_type          = var.master_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = local.master_user_data
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = var.worker_count
  ami                    = var.ami
  instance_type          = var.worker_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = local.worker_user_data
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
