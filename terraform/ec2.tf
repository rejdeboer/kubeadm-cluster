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

resource "aws_instance" "controlplane" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.cluster_key.key_name
  security_groups             = ["${aws_security_group.this.id}"]
  associate_public_ip_address = true

  subnet_id = aws_subnet.subnet.id
  tags = {
    Name = "controlplane"
  }
}

resource "aws_instance" "node01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.subnet.id
  tags = {
    Name = "node01"
  }
}

resource "aws_instance" "node02" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.subnet.id
  tags = {
    Name = "node02"
  }
}

