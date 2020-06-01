#!/usr/bin/env bash

chef_status_file="/var/chef-solo/last_run_age"
last_chef_run_ts=$(stat -c %Y $chef_status_file)
now=$(date +%s)

age=$((now - last_chef_run_ts))

printf "last_chef_run\tI\t%d\n" $age
