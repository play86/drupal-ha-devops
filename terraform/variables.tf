variable "my_ip" {
  type = string
}

variable "public_key_path" {
  default = "~/.ssh/prestashop-key.pub"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_multi_az" {
  default = false
}

