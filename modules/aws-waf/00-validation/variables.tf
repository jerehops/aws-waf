variable "rulegroup_file" {
  type = string
  description = "Path of JSON file for rulegroups"
  default = ""
}

variable "webacl_file" {
  type = string
  description = "Path of JSON file for webacl"
}

variable "run_checks" {
  type    = bool
  default = true
}