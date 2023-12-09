resource null_resource "validate_json" {
  provisioner "local-exec" {
    command = "chmod +x ./${path.module}/validate_json.sh && ./${path.module}/validate_json.sh"
    environment = {
      statement_length_check = join(",", local.statement_length_check)
      statement_check = join(",", local.statement_check)
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
  webacl_file    = jsondecode(file(var.webacl_file))
  statement_length_check = flatten([
    for item in local.webacl_file : "${item.type} ${length(item.statement)}"
  ])
  statement_check = flatten([
    for v in local.webacl_file : keys(v.statement)
  ])
}