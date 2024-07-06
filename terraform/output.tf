output "node_ips" {
  value = {
    for _, instance in aws_spot_instance_request.instances : instance.tags.Name => instance.public_ip
  }
}

