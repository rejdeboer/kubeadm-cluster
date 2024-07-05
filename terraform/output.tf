output "master_node_ip" {
  value = aws_instance.controlplane.public_ip
}

