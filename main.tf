provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "securezee_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "securezee-vpc"
  }
}

resource "aws_subnet" "securezee_subnet" {
  count = 2
  vpc_id                  = aws_vpc.securezee_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.securezee_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "securezee-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "securezee_igw" {
  vpc_id = aws_vpc.securezee_vpc.id

  tags = {
    Name = "securezee-igw"
  }
}

resource "aws_route_table" "securezee_route_table" {
  vpc_id = aws_vpc.securezee_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.securezee_igw.id
  }

  tags = {
    Name = "securezee-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.securezee_subnet[count.index].id
  route_table_id = aws_route_table.securezee_route_table.id
}

resource "aws_security_group" "securezee_cluster_sg" {
  vpc_id = aws_vpc.securezee_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "securezee-cluster-sg"
  }
}

resource "aws_security_group" "securezee_node_sg" {
  vpc_id = aws_vpc.securezee_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "securezee-node-sg"
  }
}

resource "aws_eks_cluster" "securezee" {
  name     = "securezee-cluster"
  role_arn = aws_iam_role.securezee_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.securezee_subnet[*].id
    security_group_ids = [aws_security_group.securezee_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "securezee" {
  cluster_name    = aws_eks_cluster.securezee.name
  node_group_name = "securezee-node-group"
  node_role_arn   = aws_iam_role.securezee_node_group_role.arn
  subnet_ids      = aws_subnet.securezee_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]


}

resource "aws_iam_role" "securezee_cluster_role" {
  name = "securezee-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "securezee_cluster_role_policy" {
  role       = aws_iam_role.securezee_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "securezee_node_group_role" {
  name = "securezee-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "securezee_node_group_role_policy" {
  role       = aws_iam_role.securezee_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "securezee_node_group_cni_policy" {
  role       = aws_iam_role.securezee_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "securezee_node_group_registry_policy" {
  role       = aws_iam_role.securezee_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}