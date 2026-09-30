provider "aws" {
  region = "eu-north-1" # Change to your preferred region 
}

# 1. Generate a new RSA SSH key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register the generated public key with AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "my-tfeautomatedec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# 3. Save the private key locally as a .pem file on your machine
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/my-ec2-key.pem"
  file_permission = "0400"
}


# Fetch the latest free Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

# Free-tier EC2 Resource
resource "aws_instance" "my_free_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Free-tier eligible (or "t3.micro" depending on region) [updating this to t3 since eu-north-1 is free there]

  key_name      = aws_key_pair.generated_key.key_name

  tags = {
    Name        = "MyFirst-sshkeypairassociated-AutomatedEC2"
    Environment = "Dev"
  }

}
# Output the private key directly in the CLI execution logs (marked sensitive)
output "private_key_pem" {
  description = "The raw private key content in PEM format"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}

# Output the saved .pem file location
output "private_key_path" {
  description = "Local path where the .pem file is saved"
  value       = local_file.private_key_pem.filename
}








