resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "this" {
  name = "allow-all"

  vpc_id = aws_vpc.this.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    description = "Kube API server"
  }
  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    description = "etcd database server client API"
  }
  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 6783
    to_port     = 6784
    protocol    = "udp"
    description = "Weave net UDP"
  }
  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    description = "kubelet, kube-scheduler and kube-controller"
  }
  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    description = "Weave net CNI TCP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 3, 1)
  vpc_id            = aws_vpc.this.id
  availability_zone = "eu-central-1a"
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.this.id
}
