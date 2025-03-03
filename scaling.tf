resource "aws_autoscaling_policy" "scale_policy" {
  name                   = "webserver-scale-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.name
}
