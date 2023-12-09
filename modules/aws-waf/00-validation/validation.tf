resource null_resource "validate_json" {
  provisioner "local-exec" {
    command = "chmod +x ./${path.module}/validate_json.sh && ./${path.module}/validate_json.sh"
    environment = {
      rule_group_statement_length_check = join(",", local.rule_group_statement_length_check)
      rule_group_statement_check = join(",", local.rule_group_statement_check)
      webacl_statement_check = join(",", local.webacl_statement_check)
    }
  }

  //To trigger on every run
  triggers = {
    key = "${uuid()}"
  }
}

output "result" {
  value = { validate_access = true }

  depends_on = [
    null_resource.validate_json
  ]
}


locals {
  rulegroup_file = try(jsondecode(file(var.rulegroup_file)), [])
  webacl_file    = jsondecode(file(var.webacl_file))
  rule_group_statement_length_check = flatten([
    for item in local.rulegroup_file : "${item.type} ${length(item.statement)}"
  ])
  rule_group_statement_check = flatten([
    for v in local.rulegroup_file : keys(v.statement)
  ])
  webacl_statement_check = flatten([
    for v in local.webacl_file : keys(v.statement)
  ])
}