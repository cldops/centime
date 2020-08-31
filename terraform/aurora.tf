resource "aws_db_subnet_group" "ctest" {
  name       = "main"
#  subnet_ids = data.aws_subnet_ids.ctest.ids
  subnet_ids = aws_subnet.ctest[*].id

  tags = {
    Name = "My ctest DB subnet group"
  }
}

resource "aws_security_group" "ctest-aurora" {
  name        = "terraform-eks-ctest-aurora"
  description = "Cluster communication with DB nodes"
  vpc_id      = aws_vpc.ctest.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-ctest-aurora"
  }
}

resource "aws_security_group_rule" "ctest-aurora-ingress" {
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allowing communication with the DB instances on port 3306"
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.ctest-aurora.id
  to_port           = 3306
  type              = "ingress"
}

resource "aws_rds_cluster" "ctest" {
  cluster_identifier      = var.cluster-identifier
  engine                  = var.engine
  engine_version          = var.engine-vers
  availability_zones      = values(var.subnet-numbers)
  db_subnet_group_name    = aws_db_subnet_group.ctest.name
  vpc_security_group_ids  = [aws_security_group.ctest-aurora.id]
  database_name           = var.db-name
  port                    = var.db-port
  master_username         = var.master-username
  master_password         = var.master-password
  backup_retention_period = var.retention-period
  preferred_backup_window = var.backup-window
  skip_final_snapshot     = var.skip-final-snapshot
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                  = var.cluster-size
  identifier             = "ctest-cluster-instance-identifier-${count.index}"
  cluster_identifier     = aws_rds_cluster.ctest.id
  instance_class         = var.instance-class
  db_subnet_group_name   = aws_db_subnet_group.ctest.name
  engine                 = aws_rds_cluster.ctest.engine
  engine_version         = aws_rds_cluster.ctest.engine_version
}
