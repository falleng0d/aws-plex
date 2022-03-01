// Defines where terraform will store its state
terraform {
  // Manually create this bucket before starting terraform for the first time
  backend "s3" {
    bucket  = "plexverse-state"
    key     = "terraform"
    region  = "us-east-1"
    encrypt = true
    profile = "plex"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.57"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "plex"
  region = var.region
}

resource "random_pet" "default" {
    length          = 3
    separator       = "-"
}

resource "aws_s3_bucket" "default" {
  bucket     		= "plexverse-${random_pet.default.id}"
  acl               = "private"
  force_destroy		= true
}

resource "aws_key_pair" "default" {
  key_name   = "plexverse-local-key"
  public_key = file(var.public_key_path)
}

# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "172.20.0.0/16"

  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "PlexVPC"
    Project = "Plex"
  }
}

resource "aws_security_group" "default" {
  name        = "allow_plex"
  description = "Allow Plex-related traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Plex"
    from_port   = 32400
    to_port     = 32400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Sonarr"
    from_port   = 8989
    to_port     = 8989
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Sabnzbd"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Radarr"
    from_port   = 7878
    to_port     = 7878
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Default Public Subnet
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "172.20.10.0/24" # 24
  map_public_ip_on_launch = true             # true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "DefaultPublicSubnet"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-impish-21.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "default" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.machine_type
  key_name = aws_key_pair.default.key_name

  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id              = aws_subnet.default.id

  root_block_device {
      volume_type = "gp2"
      volume_size = "256"
      delete_on_termination = true
  }

  tags = {
    Name = "plexverse"
  }
}

module "bootstrap" {
    source          = "../../modules/bootstrap"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}

module "goofys" {
    source          = "../../modules/services/goofys"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    endpoint        = "https://s3.${var.region}.amazonaws.com"
    auth_key        = csvdecode(file(var.auth_file_path))[0]["Access key ID"]
    auth_secret     = csvdecode(file(var.auth_file_path))[0]["Secret access key"]
    bucket          = "plexverse-${random_pet.default.id}"
    user            = "ubuntu"

}

module "nginx" {
    source          = "../../modules/services/nginx"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}

module "plex" {
    source          = "../../modules/apps/plex"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}

module "sabnzbd" {
    source          = "../../modules/apps/sabnzbd"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}

module "sonarr" {
    source          = "../../modules/apps/sonarr"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}

module "radarr" {
    source          = "../../modules/apps/radarr"
    private_key_path= var.private_key_path
    host            = aws_instance.default.public_ip
    user            = "ubuntu"
}
