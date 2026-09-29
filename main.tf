provider "aws" {
  region = "eu-north-1" # Change to your preferred region 
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
  instance_type = "t2.micro" # Free-tier eligible (or "t3.micro" depending on region)

  tags = {
    Name        = "MyFirstAutomatedEC2"
    Environment = "Dev"
  }
}
