
provider "aws" {
    region = "us-east-2"
}


data "aws_vpc" "default" {
  default = true
}

# Create mysql database
resource "aws_db_instance" "example" {
  identifier_prefix = "cicd-example"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  skip_final_snapshot = true
  db_name = "cicdExDB"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible = true
  
  # Better to use variables and pass as env variables via console
  username = "myusername"
  password = "mypassword"
}

# Security group for db
resource "aws_security_group" "db_sg" {
  name = "mysql-sg"
  description = "Allow mysql access"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

# Generate a key pair locally for ssh
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

# Ec2 outputs
output "ec2_public_dns" {
  value = aws_instance.cicd-example.public_dns
}
output "ec2_public_ip" {
  value = aws_instance.cicd-example.public_ip
}

# Database outputs
output "db_address" {
  value = aws_db_instance.example.address
  description = "Connect to database at this endpoint"
}
output "db_port" {
  value = aws_db_instance.example.port
  description = "The port the database is listening on"
}
