
provider "aws" {
    region = "us-east-2"
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "instance" {
  # Security group for ec2 Instance
  name = "cicd-instance"
  vpc_id = data.aws_vpc.default.id
  ingress {
    description = "HTTP on port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a key pair locally
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create AWS key pair using the public key
resource "aws_key_pair" "generated_key" {
  key_name = "cicd-terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create ec2 instance
resource "aws_instance" "cicd-example" {
  ami = "ami-0c3b809fcf2445b6a"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.name]
  key_name = aws_key_pair.generated_key.key_name
  tags = {
    Name = "cicd-example"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo snap install docker
              EOF
  user_data_replace_on_change = true
}

# Save private key to a local file
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/terraform-key.pem"
  file_permission = "0600"
}

output "public_dns" {
  value = aws_instance.cicd-example.public_dns
}
output "public_ip" {
  value = aws_instance.cicd-example.public_ip
}
