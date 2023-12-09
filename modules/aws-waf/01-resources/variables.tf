variable "name" {
  type = string
}

variable "setup_result" {}

variable "scope" {
  type = string
}

## FOR WEB ACL
variable "cloudwatch_metrics_enabled" {
  type = bool
}

variable "cloudwatch_metric_name" {
  type = string
}

variable "sampled_requests_enabled" {
  type = bool
}

variable "default_action" {
  type = string
  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Valid values expected for default actions to be one of [allow or block]"
  }
}

variable "webacl_file" {
  type = string
  description = "Path of JSON file for webacl"
}

locals {
  webacl_rules    = jsondecode(file(var.webacl_file))
}
