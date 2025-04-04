#public
# VPC 생성
resource "aws_vpc" "My" {
  cidr_block = "20.40.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Public Subnet 생성
resource "aws_subnet" "My" {
  vpc_id                  = aws_vpc.My.id
  cidr_block              = "20.40.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "My-Public-SN"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "My" {
  vpc_id = aws_vpc.My.id
  tags = {
    Name = "My-IGW"
  }
}

# Public Route Table 생성
resource "aws_route_table" "My" {
  vpc_id = aws_vpc.My.id
  tags = {
    Name = "My-Public-RT"
  }
}

# Public Route Table에 인터넷 게이트웨이 연결
resource "aws_route" "internet1" {
  route_table_id         = aws_route_table.My.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.My.id
}

# Public Subnet에 Public Route Table 연결
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.My.id
  route_table_id = aws_route_table.My.id
}


# Security Group for Public Subnet
resource "aws_security_group" "public_sg1" {
  vpc_id = aws_vpc.My.id
  name   = "MySG"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NACL 생성 (Public Subnet용)
resource "aws_network_acl" "public_acl1" {
  vpc_id = aws_vpc.My.id

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
    Name = "public-acl"
  }
}

# EC2 인스턴스 (Public Subnet)
resource "aws_instance" "MyEC2" {
  ami           = "ami-070e986143a3041b6"  # 예시로 Amazon Linux 2 AMI (리전마다 다를 수 있음)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.My.id
  vpc_security_group_ids = [aws_security_group.public_sg1.id]
  key_name   = "my-ssh-key"
  tags = {
    Name = "MyEC2"
  }
}
