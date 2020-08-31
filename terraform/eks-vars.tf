variable "aws_region" {
  default = "us-east-1"
}

variable "cluster-name" {
  default = "terraform-eks-ctest-cluster"
  type    = string
}

variable "nodegroup-name" {
  default = "terraform-eks-ctest-node"
  type    = string
}

variable "node-instance-type" {
  default = ["t2.small"]
}

variable "ec2-ssh-key" {
  default = "rvirgp"
  type    = string
}

variable "subnet-numbers" {
  description = "Map from availability zone to the number that should be used for each availability zone's subnet"
  default     = {
    1 = "us-east-1a"
    2 = "us-east-1b"
    3 = "us-east-1c"
  }
}
