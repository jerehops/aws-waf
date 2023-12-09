# Disclaimer
### **The following example is not prouduction ready and is used for education purposes only.**

# WAF Module Parameters
| **Name**                   | **Description**             |
|----------------------------|-----------------------------|
| name                       | Name of your WAF resource   |
| scope                      | Regional or CF WAF          |
| cloudwatch_metric_name     | WAF Cloudwatch metric name  |
| cloudwatch_metrics_enabled | Enable cloudwatch metrics   |
| sampled_requests_enabled   | Enable sampled requests     |
| default_action             | Default action for WAF      | 
| webacl_file                | Path of JSON file           | 

# About the project
While creating WAF module, I stumbled across many pain points and issues. 
The AWS provider for WAF does not promote DRY which makes the module very bloated.

To provide ideas and guidance, I've decided to create a baseline module that people can use to build their own consumption.
The WAF module is a nested module consisting on 2 parts - **Validation and Resource**

The validation stage does simple validation to make sure that **match** and **not** statements only contain 1 statement and statement name checks.


