#public 2

terraform {
  required_version = ">= 1.5.0"  # 최소 Terraform 버전 1.5.0 이상
}

provider "aws" { }

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block = "10.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ELB-VPC"
  }
}

# Public Subnet 생성
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELBPPublic-SN1"
  }
}

# Public Subnet 생성
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.40.2.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ELBPPublic-SN2"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ELB-IGW"
  }
}

# Public Route Table 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ELB-Public-RT"
  }
}

# Public Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


# Security Group for Public Subnet
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ELBSG"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # SSH 접근을 위해 모든 IP 허용
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH 접근을 위해 모든 IP 허용
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH 접근을 위해 모든 IP 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NACL 생성 (Public Subnet용)
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.main.id

	ingress {
		rule_no = 100
		protocol = "6" # 6 = TCP
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}

	egress {
		rule_no = 100
		protocol = "6" # 6 = TCP
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}
  tags = {
    Name = "ELB-acl"
  }
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "public1" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name   = "my-ssh-key"
  tags = {
    Name = "SERVER-1"
  }
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "public2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name   = "my-ssh-key"
  tags = {
    Name = "SERVER-2"
  }
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "public3" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name   = "my-ssh-key"
  tags = {
    Name = "SERVER-3"
  }
}
