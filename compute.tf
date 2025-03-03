resource "aws_launch_template" "webserver_lt" {
  name_prefix   = "webserver-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webserver_key.key_name

  network_interfaces {
    security_groups = [aws_security_group.webserver_sg.id]
  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  desired_capacity     = 2
  min_size            = 2
  max_size            = 5
  launch_template {
    id      = aws_launch_template.webserver_lt.id
    version = "$Latest"
  }
}
