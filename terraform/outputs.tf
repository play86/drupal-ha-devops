output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.drupal.address
}

output "efs_id" {
  value = aws_efs_file_system.files.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
