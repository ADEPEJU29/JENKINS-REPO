provider "aws" {
  region     = "us-easttt-2"
 profile = "ADEPEJU"
}

# create vpc
resource "aws_vpc" "demo" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "demo"
  }
}

# create subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  map_public_ip_on_launch = true

  tags = {
    Name = "demo_subnet"
  }
}

# create Internet Gateway and attach to vpc
resource "aws_internet_gateway" "demo_gw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "demo_gw"
  }
}

# create route table
resource "aws_route_table" "demo_RT" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_gw.id
  }

  
  tags = {
    Name = "demo_RT"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo_RT.id
}
# create security group for ec2 instance
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "web" {
  ami           = "ami-09040d770ffe2224f" # us-east-2
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  availability_zone = "us-east-2b"
  key_name = "Akeem-KEYPAIR"

  tags = {
    Name = "HelloWorld"
  }
}
