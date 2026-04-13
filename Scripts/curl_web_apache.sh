#!/bin/bash

URL="http://192.168.2.30/"
TIMEOUT=5

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time $TIMEOUT $URL)

if [ "$HTTP_CODE" = "200" ]; then
    echo 1
else
    echo 0
fi
