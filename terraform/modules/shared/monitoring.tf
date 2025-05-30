resource "aws_sns_topic" "compatibility_alarms" {
  name = "CompatibilityAlarms-${var.environment}"
}

resource "aws_sns_topic_subscription" "compatibility_alarms_subscription" {
  topic_arn = aws_sns_topic.compatibility_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "compatibility_error_alarm" {
  alarm_name          = "CompatibilityErrorAlarm-${var.environment}"
  alarm_description   = "Alarm for high error rate in compatibility functions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 5
  datapoints_to_alarm = 3
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.compatibility_alarms.arn]

  metric_query {
    id          = "error_rate"
    expression  = "100*(errors/invocations)"
    label       = "Error Rate"
    return_data = true
  }

  metric_query {
    id          = "errors"
    metric {
      metric_name = "CalculateErrors"
      namespace   = "CompatibilityMetrics"
      period      = 300
      stat        = "Sum"
    }
    return_data = false
  }

  metric_query {
    id          = "invocations"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
    }
    return_data = false
  }
}