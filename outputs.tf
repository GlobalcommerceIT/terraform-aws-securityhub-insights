output "insight_arns" {
  value = {
    for k, v in aws_securityhub_insight.this :
    k => v.arn
  }
}
