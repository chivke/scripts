#!/bin/bash
file_log=${1-'/var/log/auth.log'}
output=${2-'auth_treath.csv'}
output_controller=0
echo "auth treath check - bash script"
echo "> checking for ${file_log} file log..."
if [ -s $output ]; then
  new_output=.$output
  output_controller=1
fi
while IFS= read line; do
  treath_id=$(echo "$line" | grep "Failed password for" | cut -d " " -f 5 | sed 's/sshd\[//' | sed 's/\]://')
  treath_date=$(echo "$line" | grep "Failed password for" | cut -d " " -f 1,2,3)
  treath_user=$(echo "$line" | grep "Failed password for" | cut -d " " -f 9)
  if [ "$treath_user" == 'invalid' ]; then
    treath_user=$(echo "$line" | grep "Failed password for" | cut -d " " -f 11)
    treath_sdir=$(echo "$line" | grep "Failed password for" | cut -d " " -f 13)
    treath_sport=$(echo "$line" | grep "Failed password for" | cut -d " " -f 15)
  else
    treath_sdir=$(echo "$line" | grep "Failed password for" | cut -d " " -f 11)
    treath_sport=$(echo "$line" | grep "Failed password for" | cut -d " " -f 13)
  fi
  if [ "${treath_user}" != "" ]; then
    register="${treath_date},${treath_id},${treath_user},${treath_sdir},${treath_sport}"
    if [ $output_controller -eq 0 ]; then
      echo $register >> $output
    elif [ $output_controller -eq 1 ]; then
      echo $register >> $new_output
    fi
  fi
done <"$file_log"
echo "> completed."
if [ $output_controller -eq 1 ]; then
  while IFS= read line; do
    echo ${line#>} >> $output
    echo "new register found: ${line#>}"
  done <<<$(diff $output $new_output | grep ">")
  rm $new_output
fi
echo "> check output details in ${output} file (cat ${output})."
