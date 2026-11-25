resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "SSH to bastion from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-bastion-sg" }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  tags                        = { Name = "${var.project_name}-bastion" }
}
