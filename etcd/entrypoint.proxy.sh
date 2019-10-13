#!/bin/sh
set -ex

# find my ip
THIS_IP="$(ip addr show eth0 | grep -m 1 -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}')"
LISTEN_ADDR=$THIS_IP:2379

# for etcd proxy, specify docker service name of etcd nodes
for ip in `dig +short $ETCD_SERVICE_NAME`
do
  if [ -z "$ENDPOINTS" ]; then 
    ENDPOINTS=$ip:2379
  else
    ENDPOINTS=$ENDPOINTS,$ip:2379
  fi
done

# start etcd proxy
etcd grpc-proxy start --endpoints=$ENDPOINTS \
  --listen-addr=$LISTEN_ADDR \
  --advertise-client-url=$LISTEN_ADDR \
  --resolver-prefix="___grpc_proxy_endpoint" \
  --resolver-ttl=60
