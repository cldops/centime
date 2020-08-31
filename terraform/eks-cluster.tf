# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

resource "aws_iam_role" "ctest-cluster" {
  name = "terraform-eks-ctest-cluster"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "ctest-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ctest-cluster.name
}

resource "aws_security_group" "ctest-cluster" {
  name        = "terraform-eks-ctest-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.ctest.id

#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

#  ingress {
#    from_port       = 443
#    to_port         = 443
#    protocol        = "tcp"
#    security_groups = [aws_security_group.ctest-node.id]
#  }

  tags = {
    Name = "terraform-eks-ctest"
  }
}

resource "aws_security_group_rule" "ctest-cluster-ingress" {
  description              = "Allowing communication with the cluster API Server on port 443"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ctest-cluster.id
  source_security_group_id = aws_security_group.ctest-node.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "ctest-cluster-egress" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ctest-cluster.id
  source_security_group_id = aws_security_group.ctest-node.id
  type                     = "egress"
}

resource "aws_eks_cluster" "ctest" {
  name     = var.cluster-name
  role_arn = aws_iam_role.ctest-cluster.arn

  vpc_config {
    security_group_ids      = [aws_security_group.ctest-cluster.id]
#    subnet_ids              = data.aws_subnet_ids.ctest.ids
    subnet_ids              = aws_subnet.ctest[*].id
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  tags = {
    Name = "terraform-eks-cluster-ctest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ctest-cluster-AmazonEKSClusterPolicy,
  ]
}
