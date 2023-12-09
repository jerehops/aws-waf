#!/bin/bash

echo "Rule Group Statement Length Checks"
echo "================================="
echo rule_group_statement_length_check = $rule_group_statement_length_check
echo
echo "Rule Group Statement Checks"
echo "================================="
echo rule_group_statement_check = $rule_group_statement_check
echo
echo "WebACL Statement Checks"
echo "================================="
echo webacl_statement_check = $webacl_statement_check
echo

IFS=',' rule_group_statement_length_check=( $rule_group_statement_length_check )
IFS=',' rule_group_statement_check=( $rule_group_statement_check )
IFS=',' webacl_statement_check=( $webacl_statement_check )

if [[ $rule_group_statement_length_check != "" ]]; then
  for ((idx=0; idx<${#rule_group_statement_length_check[@]}; ++idx)); do
    rule_group_statement_length_check_values=${rule_group_statement_length_check[idx]}
    IFS=' '
    read -ra values <<< "$rule_group_statement_length_check_values"
    if [[ ("${values[0]}" == "match" || "${values[0]}" == "not") && "${values[1]}" > 1 ]];
    then
      echo "Error: Only 1 statement allowed for type Match and Not"
      exit 1
    fi
  done
fi

if [[ $rule_group_statement_check != "" ]]; then
  for ((idx=0; idx<${#rule_group_statement_check[@]}; ++idx)); do
    rule_group_statement_check_values=${rule_group_statement_check[idx]}
    read -ra values <<< "$rule_group_statement_check_values"
    if [[ "${values[@]}" != "geo_match_statement" && "${values[@]}" != "ip_set_reference_statement" && "${values[@]}" != "regex_pattern_set_reference_statement" ]];
    then
      echo "Error: Only geo_match_statement, ip_set_reference_statement, regex_pattern_set_reference_statement"
      exit 1
    fi
  done
fi

for ((idx=0; idx<${#webacl_statement_check[@]}; ++idx));
do
  webacl_statement_check_values=${webacl_statement_check[idx]}
  read -ra values <<< "$webacl_statement_check_values"
  if [[ "${values[@]}" != "rule_group_reference_statement" && "${values[@]}" != "managed_rule_group_statement" ]];
  then
    echo "Error: Only rule_group_reference_statement,managed_rule_group_statement allowed"
    exit 1
  fi
done