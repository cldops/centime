variable "instance-class" {
  type        = string
  default     = "db.t2.small"
  description = "Instance type to use"
}

variable "cluster-identifier" {
  type        = string
  default     = "aurora-cluster-ctest"
  description = "The RDS Cluster Identifier. Will use generated label ID if not supplied"
}

variable "cluster-size" {
  type        = number
  default     = 1
  description = "Number of DB instances to create in the cluster"
}

variable "db-name" {
  type        = string
  default     = "ctest"
  description = "Database name (default is not to create a database)"
}

variable "db-port" {
  type        = number
  default     = 3306
  description = "Database port"
}

variable "master-username" {
  type        = string
  default     = "admin"
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "master-password" {
  type        = string
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user"
}

variable "retention-period" {
  type        = number
  default     = 5
  description = "Number of days to retain backups for"
}

variable "backup-window" {
  type        = string
  default     = "07:00-09:00"
  description = "Daily time range during which the backups happen"
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "engine-vers" {
  type        = string
  default     = "5.7.mysql_aurora.2.04.0"
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
}

variable "skip-final-snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = true
}
