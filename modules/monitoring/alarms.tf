# High CPU Alarm: Monitors RDS performance and alerts if utilization exceeds 80%.
# This is a critical indicator of potential database bottlenecks.
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "kapuletu-${var.env}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
}
