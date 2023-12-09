#!/bin/bash

echo "Rule Group Statement Length Checks"
echo "================================="
echo statement_length_check = $statement_length_check
echo
echo "Rule Group Statement Checks"
echo "================================="
echo statement_check = $statement_check
echo

IFS=',' statement_length_check=( $statement_length_check )
IFS=',' statement_check=( $statement_check )

if [[ $statement_length_check != "" ]]; then
  for ((idx=0; idx<${#statement_length_check[@]}; ++idx)); do
    statement_length_check_values=${statement_length_check[idx]}
    IFS=' '
    read -ra values <<< "$statement_length_check_values"
    if [[ ("${values[0]}" == "match" || "${values[0]}" == "not") && "${values[1]}" > 1 ]];
    then
      echo "Error: Only 1 statement allowed for type Match and Not"
      exit 1
    fi
  done
fi

if [[ $statement_check != "" ]]; then
  for ((idx=0; idx<${#statement_check[@]}; ++idx)); do
    statement_check_values=${statement_check[idx]}
    read -ra values <<< "$statement_check_values"
    if [[ "${values[@]}" != "geo_match_statement" && "${values[@]}" != "ip_set_reference_statement" && "${values[@]}" != "regex_pattern_set_reference_statement" && "${values[@]}" != "rule_group_reference_statement" && "${values[@]}" != "managed_rule_group_statement" ]];
    then
      echo "Error: Only geo_match_statement, ip_set_reference_statement, regex_pattern_set_reference_statement, rule_group_reference_statement, managed_rule_group_statement allowed"
      exit 1
    fi
  done
fi