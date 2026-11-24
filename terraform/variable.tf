variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "drupal-ha"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}
