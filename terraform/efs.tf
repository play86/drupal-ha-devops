resource "aws_efs_file_system" "files" {
  encrypted = true
  tags      = { Name = "${var.project_name}-efs" }
}

resource "aws_efs_mount_target" "files" {
  count           = 2
  file_system_id  = aws_efs_file_system.files.id
  subnet_id       = aws_subnet.app[count.index].id
  security_groups = [aws_security_group.efs.id]
}
