# Input variables for the RDS module.
variable "env" {
  description = "The deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "The instance type for the RDS database"
  type        = string
  default     = "db.t3.micro"
}
