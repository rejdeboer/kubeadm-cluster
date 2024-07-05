resource "aws_key_pair" "cluster_key" {
  key_name   = "cluster-key"
  public_key = tls_private_key.cluster_key.public_key_openssh
}

resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "cluster_key" {
  content         = tls_private_key.cluster_key.private_key_pem
  filename        = "../${aws_key_pair.cluster_key.key_name}.pem"
  file_permission = "600"
}
