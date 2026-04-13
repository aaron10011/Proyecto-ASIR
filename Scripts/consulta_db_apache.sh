#!/bin/bash

mysql -h 192.168.2.20 -u monitor_zabbix -p'0408' -e "SELECT 1;" web_formularios >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo 1
else
  echo 0
fi
