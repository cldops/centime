# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * Security group for allowing incoming connections to nodes
#  * EKS Node Group to launch worker nodes

resource "aws_iam_role" "ctest-node" {
  name = "terraform-eks-ctest-node"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "ctest-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ctest-node.name
}

resource "aws_iam_role_policy_attachment" "ctest-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ctest-node.name
}

resource "aws_iam_role_policy_attachment" "ctest-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ctest-node.name
}

resource "aws_security_group" "ctest-node" {
  name        = "terraform-eks-ctest-node"
  description = "worker communication rule"
  vpc_id      = aws_vpc.ctest.id

  tags = {
    Name = "nodes-sg"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ctest-node.id
  source_security_group_id = aws_security_group.ctest-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ctest-node.id
  source_security_group_id = aws_security_group.ctest-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_traffic_inbound" {
  cidr_blocks              = ["10.0.0.0/16"]
  description              = "Allow traffic to worker nodes"
  from_port                = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ctest-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_eks_node_group" "ctest" {
  cluster_name    = aws_eks_cluster.ctest.name
  node_group_name = var.nodegroup-name
  instance_types  = var.node-instance-type
  node_role_arn   = aws_iam_role.ctest-node.arn
#  subnet_ids      = data.aws_subnet_ids.ctest.ids
  subnet_ids      = aws_subnet.ctest[*].id

  remote_access {
    ec2_ssh_key   	      = var.ec2-ssh-key
    source_security_group_ids = [aws_security_group.ctest-node.id]
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  tags = map(
    "Name", "terraform-eks-node-ctest",
    "kubernetes.io/cluster/${var.cluster-name}", "owned",
  )

  depends_on = [
    aws_iam_role_policy_attachment.ctest-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.ctest-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ctest-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
