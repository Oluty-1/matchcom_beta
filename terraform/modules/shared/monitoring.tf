resource "aws_sns_topic" "compatibility_alarms" {
  name = "CompatibilityAlarms-${var.environment}"
}

resource "aws_sns_topic_subscription" "compatibility_alarms_subscription" {
  topic_arn = aws_sns_topic.compatibility_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

locals {
  lambda_functions = [
    "CalculateCompatibilityFunction",
    "ProcessCompatibilityFunction",
    "GetCompatibilityFunction",
    "UpdateCompatibilityFunction",
    "DeleteCompatibilityFunction"
  ]
}

resource "aws_cloudwatch_metric_alarm" "compatibility_error_alarm" {
  for_each            = toset(local.lambda_functions)
  alarm_name          = "${each.key}-ErrorAlarm-${var.environment}"
  alarm_description   = "Alarm for high error rate in ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 5  # 5% error rate
  datapoints_to_alarm = 3
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.compatibility_alarms.arn]

  metric_query {
    id          = "error_rate"
    expression  = "100*(errors/invocations)"
    label       = "Error Rate (%)"
    return_data = true
  }

  metric_query {
    id          = "errors"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = each.key
      }
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
      dimensions = {
        FunctionName = each.key
      }
    }
    return_data = false
  }
}

# resource "aws_cloudwatch_metric_alarm" "concurrency_alarm" {
#   for_each            = toset(local.lambda_functions)
#   alarm_name          = "${each.key}-HighConcurrencyAlarm-${var.environment}"
#   alarm_description   = "Alarm for high concurrent executions in ${each.key}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   threshold           = 8  # Alert if nearing reserved concurrency limit (10)
#   datapoints_to_alarm = 2
#   actions_enabled     = true
#   alarm_actions       = [aws_sns_topic.compatibility_alarms.arn]
# 
#   metric_name = "ConcurrentExecutions"
#   namespace   = "AWS/Lambda"
#   period      = 300
#   stat        = "Maximum"
#   dimensions = {
#     FunctionName = each.key
#   }
# }

resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "CompatibilityLambdaDashboard-${var.environment}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "CalculateCompatibilityFunction"],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "ConcurrentExecutions", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "CalculateCompatibilityFunction Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Error Threshold"
                value = 5
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "ProcessCompatibilityFunction"],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "ConcurrentExecutions", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "ProcessCompatibilityFunction Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Error Threshold"
                value = 5
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "GetCompatibilityFunction"],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "ConcurrentExecutions", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "GetCompatibilityFunction Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Error Threshold"
                value = 5
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "UpdateCompatibilityFunction"],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "ConcurrentExecutions", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "UpdateCompatibilityFunction Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Error Threshold"
                value = 5
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "DeleteCompatibilityFunction"],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "ConcurrentExecutions", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "DeleteCompatibilityFunction Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Error Threshold"
                value = 5
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "CompatibilityQueue-${var.environment}"],
            [".", "NumberOfMessagesSent", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "SQS CompatibilityQueue Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Queue Depth Warning"
                value = 100
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          region  = var.region
          metrics = [
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", "CompatibilityResults-${var.environment}"],
            [".", "ReadThrottleEvents", ".", "."],
            [".", "WriteThrottleEvents", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "DynamoDB CompatibilityResults Metrics"
          period  = 300
          annotations = {
            horizontal = [
              {
                label = "Throttle Warning"
                value = 10
              }
            ]
          }
        }
      }
    ]
  })
}