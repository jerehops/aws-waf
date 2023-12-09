module "validation" {
  source = "./00-validation"
  webacl_file    = var.webacl_file
}

module "resources" {
  source = "./01-resources"

  # This forces implicit depends on
  setup_result               = module.validation.result

  name                       = var.name
  scope                      = var.scope
  cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
  cloudwatch_metric_name     = var.cloudwatch_metric_name
  sampled_requests_enabled   = var.sampled_requests_enabled
  default_action             = var.default_action
  webacl_file                = var.webacl_file
}