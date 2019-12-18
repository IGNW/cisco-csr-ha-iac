#!/bin/bash

desktop_nodes=`terraform state list | grep desktop`
course_name=`terraform state show aws_instance.desktop[0] | grep 'tags.Project' | cut -f2 -d '=' | sed s/^\ //g | sed s/\ /_/g`

if [ -f export/$course_name.csv ]; then
  rm export/$course_name.csv
fi

echo 'Desktop Name,Public IP' > export/$course_name.csv

for i in $desktop_nodes; do
    name=`terraform state show $i | grep 'tags.Name' | cut -f2 -d '=' | tr -d '[:space:]'`
    ip=`terraform state show $i | grep 'public_ip ' | cut -f2 -d '='`

    echo "$name,$ip" >> export/$course_name.csv
done

zip -r export/$course_name.zip export/id_rsa export/id_rsa.pub export/$course_name.csv
