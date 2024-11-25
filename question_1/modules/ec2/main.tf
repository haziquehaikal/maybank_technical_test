# SSM Configuration
resource "aws_ssm_document" "ssm_port_foward_document" {
  name          = "SSMPortForwardDocument"
  document_type = "Session"
  content       = <<EOF
{
  "schemaVersion": "1.0",
  "sessionType": "Port",
  "inputs": {
    "portNumber": "3360",
    "localPortNumber": "3360"
  }
}
EOF
}


resource "aws_iam_role" "ssm_role" {
  name               = "SSMPortForwardingRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_network_interface_sg_attachment" "ssm_sg_attachment" {
  security_group_id    = var.ssm_sg_id
  network_interface_id = aws_instance.ssm_host.primary_network_interface_id
}

# EC2 instance 
resource "aws_instance" "ssm_host" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_id
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  tags = {
    Name = "SSM Host"
  }
}

resource "aws_launch_configuration" "server" {
  name            = "server-asg-config"
  image_id        = var.image_id
  instance_type   = var.instance_type
  security_groups = var.security_group_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.private_subnet_id
  launch_configuration = aws_launch_configuration.server.id
}
