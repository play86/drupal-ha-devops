data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_launch_template" "app" {
  name_prefix            = "${var.project_name}-lt-"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    echo "<h1>DOMinion HA node $(hostname)</h1>" > /var/www/html/index.html
  EOT
  )
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-app" }
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.project_name}-asg"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.app[*].id
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  depends_on = [aws_nat_gateway.nat]
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project_name}-cpu60"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}
