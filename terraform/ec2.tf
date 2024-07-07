data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  nodes = ["controlplane", "node01", "node02"]
}

resource "aws_spot_instance_request" "instances" {
  for_each                    = toset(local.nodes)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.cluster_key.key_name
  security_groups             = ["${aws_security_group.this.id}"]
  associate_public_ip_address = true
  wait_for_fulfillment        = true

  subnet_id = aws_subnet.subnet.id
  tags = {
    Name = each.key
  }

  user_data = <<-EOL
  #!/bin/bash 

  sudo swapoff -a

  # Creating containerd configuration file with list of necessary modules that need to be loaded with containerd
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
  overlay
  br_netfilter
  EOF

  # Load containerd modules
  sudo modprobe overlay
  sudo modprobe br_netfilter

  # sysctl params required by setup, params persist across reboots
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-iptables  = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward                 = 1
  EOF
  sudo sysctl --system
  sudo apt-get update
  sudo apt-get -y install containerd
  sudo mkdir -p /etc/containerd
  sudo containerd config default | sudo tee /etc/containerd/config.toml
  sudo systemctl restart containerd

  sudo apt-get install -y apt-transport-https ca-certificates curl gpg
  sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  #sudo systemctl enable --now kubelet
  alias k=kubectl
  EOL
}

