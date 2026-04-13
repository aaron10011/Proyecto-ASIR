#!/bin/bash

if ping -c 4 -I enp0s3 8.8.8.8 >> /dev/null; then
        echo 1
else
        echo 0

fi
