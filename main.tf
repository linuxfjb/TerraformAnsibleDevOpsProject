
#get the latest AMI id from amazon search utility
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "VPC terraform Project"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "terraform gateway Project"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "terraform subnet project"
  }
}

resource "aws_security_group" "allow_ssh_terraform" {
  name = "terraform_security_ssh"
  description = "Allow inbound SSH traffic from my IP"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_route_table" "terraform_attach_gateway" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "terraform default routing table"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  #NOTE: You must insert your local user's public key file information here.
  #You will *not* be able to SSH into your EC2 instance without replacing this
  #first.
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC27JGafI5Ml92SH8b0kpLPnNKKY/ZaXpetqFNU484qa03s5SWOJMPgVtbDKGYwD1cyxXLeGLzUZMGahEhSBF4Dp6FRx9QFL7FBjjb/6R8lVWiwKq2ID1VovISyDDhd9DLiMznnfwIz5Qxx1Em9L3iYSZcliiQ+M2WZy4Q59ZeTkQheBKcsTjgxA1jQpTlB3sOLs3Sc0lmn/LUFzezKQafGndANt8lxGvsbPgAzihgiV3QttaQR+dLYhw8fEVacLu3DxlkkzZQbkWMLPyUg1ks6wG9MgNVWRsEMSdezwPo3NBkeVeo+1/sUHWk3FLJUEwkTQkdj/i9+gGp9hMJrx/nJ linuxfjbgmail@ip-172-31-70-84"
}

# set up ec2 instance and auto-assign public IP
# and specify root_block_device storage
resource "aws_instance" "webjekyl" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  root_block_device {
      volume_type = "gp2"
      volume_size = 8
  }

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]
  subnet_id = aws_subnet.main.id

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "My EC2 instance"
  }
}

