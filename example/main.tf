module "mywaf" {
  source = "../modules/aws-waf"

  name = "jhps-demo"
  scope = "REGIONAL"

  default_action = "allow"

  cloudwatch_metric_name = "jhps-cw-logs"
  cloudwatch_metrics_enabled = true
  sampled_requests_enabled = true

  webacl_file = "waf.json"
}