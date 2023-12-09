variable "name" {
  type = string
}

variable "scope" {
  type = string
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Valid values expected for scope to be one of [CLOUDFRONT or REGIONAL]"
  }
}

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
