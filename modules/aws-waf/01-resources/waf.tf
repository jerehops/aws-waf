resource "aws_wafv2_web_acl" "aws_waf" {
  name  = "${var.name}-webacl"
  scope = var.scope
  visibility_config {
    sampled_requests_enabled   = var.sampled_requests_enabled
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = var.cloudwatch_metric_name
  }

  dynamic "default_action" {
    for_each = var.default_action == "allow" ? ["allow"] : []
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = var.default_action == "block" ? ["block"] : []
    content {
      block {}
    }
  }
  dynamic "rule" {
    for_each = local.webacl_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        none {}
      }
      dynamic "action" {
        for_each = try(lower(rule.value.action.type), "") == "allow" ? ["allow"] : []
        content {
          allow {
            dynamic "custom_request_handling" {
              for_each = try(rule.value.action.custom_request_handling != null, false) ? [
                "custom_request_handling"
              ] : []
              content {
                dynamic "insert_header" {
                  for_each = rule.value.action.custom_request_handling.insert_header
                  content {
                    name  = insert_header.value.name
                    value = insert_header.value.value
                  }
                }
              }
            }
          }
        }
      }
      dynamic "action" {
        for_each = try(lower(rule.value.action.type), "") == "block" ? ["block"] : []
        content {
          block {
            dynamic "custom_response" {
              for_each = try(rule.value.action.custom_response != null, false) ? ["custom_response"] : []
              content {
                response_code = rule.value.action.custom_response.response_code
                dynamic "response_header" {
                  for_each = rule.value.action.custom_response.response_header
                  content {
                    name  = response_header.value.name
                    value = response_header.value.value
                  }
                }
              }
            }
          }
        }
      }
      dynamic "statement" {
        for_each = rule.value.statement != null ? ["statement"] : []
        content {
          dynamic "geo_match_statement" {
            for_each = rule.value.type == "match" ? try(lookup(rule.value.statement, "geo_match_statement", null) != null, false) ? [
              "geo_match_statement"
            ] : [] : []
            content {
              country_codes = rule.value.statement.geo_match_statement.country_codes
              dynamic "forwarded_ip_config" {
                for_each = try(rule.value.statement.geo_match_statement.forwarded_ip_config, [])
                content {
                  fallback_behavior = rule.value.statement.geo_match_statement.forwarded_ip_config.fallback_behavior
                  header_name       = rule.value.statement.geo_match_statement.forwarded_ip_config.header_name
                }
              }
            }
          }
          dynamic "ip_set_reference_statement" {
            for_each = rule.value.type == "match" ? try(lookup(rule.value.statement, "ip_set_reference_statement", null) != null, false) ? [
              "ip_set_reference_statement"
            ] : [] : []
            content {
              arn = rule.value.statement.ip_set_reference_statement.arn
              dynamic "ip_set_forwarded_ip_config" {
                for_each = try(rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config, [])
                content {
                  fallback_behavior = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.fallback_behavior
                  header_name       = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.header_name
                  position          = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.position
                }
              }
            }
          }
          dynamic "regex_pattern_set_reference_statement" {
            for_each = rule.value.type == "match" ? try(lookup(rule.value.statement, "regex_pattern_set_reference_statement", null) != null, false) ? [
              "regex_pattern_set_reference_statement"
            ] : [] : []
            content {
              arn = rule.value.statement.regex_pattern_set_reference_statement.arn
              text_transformation {
                priority = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.priority
                type     = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.type
              }
              dynamic "field_to_match" {
                for_each = rule.value.statement.regex_pattern_set_reference_statement.field_to_match == "body" ? [
                  "body"
                ] : []
                content {
                  body {}
                }
              }
            }
          }
          dynamic "not_statement" {
            for_each = rule.value.type == "not" ? ["not_statement"] : []
            content {
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "geo_match_statement", null) != null, false) ? [
                  "geo_match_statement"
                ] : []
                content {
                  geo_match_statement {
                    country_codes = rule.value.statement.geo_match_statement.country_codes
                    dynamic "forwarded_ip_config" {
                      for_each = try(rule.value.statement.geo_match_statement.forwarded_ip_config, [])
                      content {
                        fallback_behavior = rule.value.statement.geo_match_statement.forwarded_ip_config.fallback_behavior
                        header_name       = rule.value.statement.geo_match_statement.forwarded_ip_config.header_name
                      }
                    }
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "ip_set_reference_statement", null) != null, false) ? [
                  "ip_set_reference_statement"
                ] : []
                content {
                  ip_set_reference_statement {
                    arn = rule.value.statement.ip_set_reference_statement.arn
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "regex_pattern_set_reference_statement", null) != null, false) ? [
                  "regex_pattern_set_reference_statement"
                ] : []
                content {
                  regex_pattern_set_reference_statement {
                    arn = rule.value.statement.regex_pattern_set_reference_statement.arn
                    text_transformation {
                      priority = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.priority
                      type     = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.type
                    }
                    dynamic "field_to_match" {
                      for_each = rule.value.statement.regex_pattern_set_reference_statement.field_to_match == "body" ? [
                        "body"
                      ] : []
                      content {
                        body {}
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "or_statement" {
            for_each = rule.value.type == "or" ? ["or_statement"] : []
            content {
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "geo_match_statement", null) != null, false) ? [
                  "geo_match_statement"
                ] : []
                content {
                  geo_match_statement {
                    country_codes = rule.value.statement.geo_match_statement.country_codes
                    dynamic "forwarded_ip_config" {
                      for_each = try(rule.value.statement.geo_match_statement.forwarded_ip_config, [])
                      content {
                        fallback_behavior = rule.value.statement.geo_match_statement.forwarded_ip_config.fallback_behavior
                        header_name       = rule.value.statement.geo_match_statement.forwarded_ip_config.header_name
                      }
                    }
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "ip_set_reference_statement", null) != null, false) ? [
                  "ip_set_reference_statement"
                ] : []
                content {
                  ip_set_reference_statement {
                    arn = rule.value.statement.ip_set_reference_statement.arn
                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = try(rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config, [])
                      content {
                        fallback_behavior = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.fallback_behavior
                        header_name       = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.header_name
                        position          = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.position
                      }
                    }
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "regex_pattern_set_reference_statement", null) != null, false) ? [
                  "regex_pattern_set_reference_statement"
                ] : []
                content {
                  regex_pattern_set_reference_statement {
                    arn = rule.value.statement.regex_pattern_set_reference_statement.arn
                    text_transformation {
                      priority = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.priority
                      type     = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.type
                    }
                    dynamic "field_to_match" {
                      for_each = rule.value.statement.regex_pattern_set_reference_statement.field_to_match == "body" ? [
                        "body"
                      ] : []
                      content {
                        body {}
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "and_statement" {
            for_each = rule.value.type == "and" ? ["and_statement"] : []
            content {
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "geo_match_statement", null) != null, false) ? [
                  "geo_match_statement"
                ] : []
                content {
                  geo_match_statement {
                    country_codes = rule.value.statement.geo_match_statement.country_codes
                    dynamic "forwarded_ip_config" {
                      for_each = try(rule.value.statement.geo_match_statement.forwarded_ip_config, [])
                      content {
                        fallback_behavior = rule.value.statement.geo_match_statement.forwarded_ip_config.fallback_behavior
                        header_name       = rule.value.statement.geo_match_statement.forwarded_ip_config.header_name
                      }
                    }
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "ip_set_reference_statement", null) != null, false) ? [
                  "ip_set_reference_statement"
                ] : []
                content {
                  ip_set_reference_statement {
                    arn = rule.value.statement.ip_set_reference_statement.arn
                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = try(rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config, [])
                      content {
                        fallback_behavior = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.fallback_behavior
                        header_name       = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.header_name
                        position          = rule.value.statement.ip_set_reference_statement.ip_set_forwarded_ip_config.position
                      }
                    }
                  }
                }
              }
              dynamic "statement" {
                for_each = try(lookup(rule.value.statement, "regex_pattern_set_reference_statement", null) != null, false) ? [
                  "regex_pattern_set_reference_statement"
                ] : []
                content {
                  regex_pattern_set_reference_statement {
                    arn = rule.value.statement.regex_pattern_set_reference_statement.arn
                    text_transformation {
                      priority = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.priority
                      type     = rule.value.statement.regex_pattern_set_reference_statement.text_transformation.type
                    }
                    dynamic "field_to_match" {
                      for_each = rule.value.statement.regex_pattern_set_reference_statement.field_to_match == "body" ? [
                        "body"
                      ] : []
                      content {
                        body {}
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "rule_group_reference_statement" {
            for_each = try(lookup(rule.value.statement, "rule_group_reference_statement", null) != null, false) ? [
              "rule_group_reference_statement"
            ] : []
            content {
              arn = rule.value.statement.regex_pattern_set_reference_statement.arn
            }
          }
          dynamic "managed_rule_group_statement" {
            for_each = try(lookup(rule.value.statement, "managed_rule_group_statement", null) != null, false) ? [
              "managed_rule_group_statement"
            ] : []
            content {
              name        = rule.value.statement.managed_rule_group_statement.name
              vendor_name = rule.value.statement.managed_rule_group_statement.vendor_name
              dynamic "managed_rule_group_configs" {
                for_each = try(lookup(rule.value.statement.managed_rule_group_statement, "managed_rule_group_configs", null) != null, false) ? [
                  "managed_rule_group_configs"
                ] : []
                content {
                  dynamic "aws_managed_rules_bot_control_rule_set" {
                    for_each = try(lookup(rule.value.statement.managed_rule_group_statement.managed_rule_group_configs, "aws_managed_rules_bot_control_rule_set", null) != null, false) ? [
                      "aws_managed_rules_bot_control_rule_set"
                    ] : []
                    content {
                      inspection_level = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_bot_control_rule_set.inspection_level
                    }
                  }
                  dynamic "aws_managed_rules_acfp_rule_set" {
                    for_each = try(lookup(rule.value.statement.managed_rule_group_statement.managed_rule_group_configs, "aws_managed_rules_acfp_rule_set", null) != null, false) ? [
                      "aws_managed_rules_acfp_rule_set"
                    ] : []
                    content {
                      creation_path          = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.creation_path
                      enable_regex_in_path   = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.enable_regex_in_path
                      registration_page_path = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.registration_page_path
                      dynamic "request_inspection" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set, "request_inspection", null) != null, false) ? [
                          "aws_managed_rules_acfp_rule_set"
                        ] : []
                        content {
                          payload_type = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.request_inspection.payload_type
                          username_field {
                            identifier = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.request_inspection.username_field
                          }
                          password_field {
                            identifier = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_acfp_rule_set.request_inspection.password_field
                          }
                        }
                      }
                    }
                  }
                  dynamic "aws_managed_rules_atp_rule_set" {
                    for_each = try(lookup(rule.value.statement.managed_rule_group_statement.managed_rule_group_configs, "aws_managed_rules_atp_rule_set", null) != null, false) ? [
                      "aws_managed_rules_atp_rule_set"
                    ] : []
                    content {
                      login_path           = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set.login_path
                      enable_regex_in_path = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set.enable_regex_in_path
                      dynamic "request_inspection" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set, "request_inspection", null) != null, false) ? [
                          "aws_managed_rules_atp_rule_set"
                        ] : []
                        content {
                          payload_type = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set.request_inspection.payload_type
                          username_field {
                            identifier = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set.request_inspection.username_field
                          }
                          password_field {
                            identifier = rule.value.statement.managed_rule_group_statement.managed_rule_group_configs.aws_managed_rules_atp_rule_set.request_inspection.password_field
                          }
                        }
                      }
                    }
                  }
                }
              }
              dynamic "rule_action_override" {
                for_each = try(rule.value.statement.managed_rule_group_statement.rule_action_override.allow != null, false) ? [
                  "allow"
                ] : []
                content {
                  name = rule_action_override.value
                  action_to_use {
                    allow {
                      dynamic "custom_request_handling" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override, "custom_request_handling", null) != null, false) ? [
                          "custom_request_handling"
                        ] : []
                        content {
                          insert_header {
                            name  = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.name
                            value = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                }
              }
              dynamic "rule_action_override" {
                for_each = try(rule.value.statement.managed_rule_group_statement.rule_action_override.block != null, false) ? [
                  "block"
                ] : []
                content {
                  name = rule_action_override.value
                  action_to_use {
                    block {
                      dynamic "custom_response" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override, "custom_response", null) != null, false) ? [
                          "custom_response"
                        ] : []
                        content {
                          response_code = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.insert_header.response_code
                          dynamic "response_header" {
                            for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response, "response_header", null ) != null, false) ? [
                              "response_header"
                            ] : []
                            content {
                              name  = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.response_header.name
                              value = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.response_header.value
                            }
                          }
                          dynamic "custom_response_body" {
                            for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response, "response_header", null) != null, false) ? [
                              "custom_response_body"
                            ] : []
                            content {
                              key          = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.custom_response_body.key
                              content      = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.custom_response_body.content
                              content_type = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_response.custom_response_body.content_type
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              dynamic "rule_action_override" {
                for_each = try(rule.value.statement.managed_rule_group_statement.rule_action_override.captcha != null, false) ? [
                  "captcha"
                ] : []
                content {
                  name = rule_action_override.value
                  action_to_use {
                    captcha {
                      dynamic "custom_request_handling" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override.captcha, "custom_request_handling", null) != null, false) ? [
                          "custom_request_handling"
                        ] : []
                        content {
                          insert_header {
                            name  = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.name
                            value = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                }
              }
              dynamic "rule_action_override" {
                for_each = try(rule.value.statement.managed_rule_group_statement.rule_action_override.challenge != null, false) ? [
                  "challenge"
                ] : []
                content {
                  name = rule_action_override.value
                  action_to_use {
                    challenge {
                      dynamic "custom_request_handling" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override, "custom_request_handling", null) != null, false) ? [
                          "custom_request_handling"
                        ] : []
                        content {
                          insert_header {
                            name  = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.name
                            value = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                }
              }
              dynamic "rule_action_override" {
                for_each = try(rule.value.statement.managed_rule_group_statement.rule_action_override.count != null, false) ? [
                  "count"
                ] : []
                content {
                  name = rule_action_override.value
                  action_to_use {
                    count {
                      dynamic "custom_request_handling" {
                        for_each = try(lookup(rule.value.statement.managed_rule_group_statement.rule_action_override.count, "custom_request_handling", null) != null, false) ? [
                          "custom_request_handling"
                        ] : []
                        content {
                          insert_header {
                            name  = rule.value.statement.managed_rule_group_statement.rule_action_override.custom_request_handling.insert_header.name
                            value = rule.value.statement.managed_rule_group_statement.count.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? ["visibility_config"] : []
        content {
          sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
          cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
          metric_name                = rule.value.visibility_config.metric_name
        }
      }
    }
  }
}
