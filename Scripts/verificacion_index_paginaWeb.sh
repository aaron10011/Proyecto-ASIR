#!/bin/bash

FILE="/var/www/formulario_mysql/index.php"

if [ -f "$FILE" ]; then
    echo 1
else
    echo 0
fi
