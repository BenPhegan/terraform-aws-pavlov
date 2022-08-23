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

resource "aws_instance" "pavlov" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.pavlov.id
  vpc_security_group_ids      = [aws_security_group.pavlov.id]
  iam_instance_profile        = aws_iam_instance_profile.pavlov.name
  monitoring                  = false
  associate_public_ip_address = true
  key_name                    = aws_key_pair.pavlov.key_name
  user_data = base64encode(templatefile("${path.module}/userdata.tmpl", {
    pavlov_api_key = var.pavlov_api_key
    rcon_password  = var.rcon_password
    server_name    = var.server_name
    moderators     = var.moderators
  }))
  tags = {
    Name = "Pavlov - ${var.server_name}"
  }
}

resource "tls_private_key" "pavlov" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pavlov" {
  key_name   = "Pavlov"
  public_key = tls_private_key.pavlov.public_key_openssh
}

resource "aws_iam_instance_profile" "pavlov" {
  name = "SSM-Instance-Profile"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "ssm" {
  name               = "SSM-Role"
  description        = "EC2 SSM Access Role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_vpc" "pavlov" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Pavlov"
  }
}

# Add a single private subnet to the VPC
resource "aws_subnet" "pavlov" {
  vpc_id            = aws_vpc.pavlov.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Pavlov"
  }
}

# Add an internet gateway to the VPC
resource "aws_internet_gateway" "pavlov" {
  vpc_id = aws_vpc.pavlov.id
}

# Add a route table to the public subnet and associate the internet gateway
resource "aws_route_table" "pavlov" {
  vpc_id = aws_vpc.pavlov.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavlov.id
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "pavlov" {
  subnet_id      = aws_subnet.pavlov.id
  route_table_id = aws_route_table.pavlov.id
}

# Add a security group that allows all traffic from all internet sources
#Rules:
#   Type: Custom ICMP Rule - IPV4 / Protocol: Echo Request
#   Type: Custom UDP Rule / Port Range: 7777 / Source: 0.0.0.0/0
#   Type: Custom UDP Rule / Port Range: 8177 / Source: 0.0.0.0/0
#   Type: SSH (optional, but I assume you wanna SSH in..)

resource "aws_security_group" "pavlov" {
  name        = "Pavlov"
  vpc_id      = aws_vpc.pavlov.id
  description = "Pavlov security group"
  ingress {
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 7777
    to_port     = 7777
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8177
    to_port     = 8177
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Pavlov"
  }
}

output "ec2_global_ips" {
  value = ["${aws_instance.pavlov.*.public_ip}"]
}