# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "CompatibilityAlerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.analytics_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.analytics_emails[count.index]
}

# X-Ray IAM Permission
resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# CloudWatch Metrics IAM Permission
resource "aws_iam_role_policy" "cloudwatch_metrics" {
  name   = "${var.function_name}-CloudWatchMetrics-${var.environment}"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "cloudwatch:PutMetricData"
        Resource = "*"
      }
    ]
  })
}

# Metric Filter for Lambda Logs
resource "aws_cloudwatch_log_metric_filter" "latency" {
  name           = "${var.function_name}-LatencyFilter-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.logs.name
  pattern        = "{ $.level = \"Info\" || $.level = \"Error\" }" # Match structured logs
  metric_transformation {
    name      = "Latency"
    namespace = "Compatibility-Monitoring"
    value     = "$.latency"
    dimensions = {
      Operation = "$.operation"
      Status    = "$.status"
    }
  }
}

# Alarms for Error Rates
locals {
  operations = {
    "CalculateCompatibilityFunction" = "POST"
    "ProcessCompatibilityFunction"   = "SQS"
    "GetCompatibilityFunction"      = "GET"
    "UpdateCompatibilityFunction"   = "PUT"
    "DeleteCompatibilityFunction"   = "DELETE"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  for_each            = local.operations
  alarm_name          = "${var.function_name}-${each.value}-ErrorRate-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 100
  alarm_description   = "Error rate for ${each.value} operation in ${var.function_name}"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "error_rate"
    label       = "Error Rate"
    return_data = true
    expression  = "100*(errors/requests)"
  }

  metric_query {
    id          = "errors"
    label       = "Errors"
    expression  = "SUM([e400,e401,e403,e404,e406,e500])"
    return_data = false
  }

  metric_query {
    id          = "e400"
    label       = "400 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "400"
      }
    }
  }

  metric_query {
    id          = "e401"
    label       = "401 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "401"
      }
    }
  }

  metric_query {
    id          = "e403"
    label       = "403 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "403"
      }
    }
  }

  metric_query {
    id          = "e404"
    label       = "404 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "404"
      }
    }
  }

  metric_query {
    id          = "e406"
    label       = "406 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "406"
      }
    }
  }

  metric_query {
    id          = "e500"
    label       = "500 Errors"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "500"
      }
    }
  }

  metric_query {
    id          = "requests"
    label       = "All Requests"
    expression  = "SUM(METRICS())"
    return_data = false
  }

  metric_query {
    id          = "ok"
    label       = "200 OK"
    return_data = false
    metric {
      metric_name = "Latency"
      namespace   = "Compatibility-Monitoring"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        Operation = each.value
        Status    = "200"
      }
    }
  }
}