#!/bin/bash
#set -x

delete_all_default_routes() {
    ip route show default | while read -r line; do
        gw=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="via") print $(i+1)}')
        dev=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}')
        if [[ -n "$gw" && -n "$dev" ]]; then
            ip route del default via "$gw" dev "$dev" || true
        fi
    done
}
delete_all_default_routes
ip route add default via 192.168.2.1 dev enp0s3 metric 50
if ping -c 2 -I enp0s3 8.8.8.8 > /dev/null; then
    delete_all_default_routes
    ip route add default via 192.168.2.1 dev enp0s3 metric 50
else
    delete_all_default_routes
    ip route add default via 192.168.1.1 dev enp0s8 metric 50
fi
