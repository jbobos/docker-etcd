#!/bin/sh
set -ex

# find my ip
THIS_IP="$(ip addr show eth0 | grep -m 1 -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}')"

# find my hostname from docker embeded DNS server
THIS_NAME="$(dig +short -x $THIS_IP | cut -d'.' -f1)"

# find all containers from docker dns by service name
# then make up the initial cluster
SERVICE_NAME="$(echo $THIS_NAME | cut -d'_' -f2)"
for ip in `dig +short $SERVICE_NAME`
do
  name="$(dig +short -x $ip | cut -d'.' -f1)"
  if [ -z "$THIS_CLUSTER" ]; then 
    THIS_CLUSTER=$name=http://$ip:2380
  else
    THIS_CLUSTER=$THIS_CLUSTER,$name=http://$ip:2380
  fi
done

# start etcd server
etcd --name $THIS_NAME \
  --data-dir /etcd-data/$THIS_NAME \
  --initial-advertise-peer-urls http://$THIS_IP:2380 \
  --listen-peer-urls http://$THIS_IP:2380 \
  --listen-client-urls http://$THIS_IP:2379 \
  --advertise-client-urls http://$THIS_IP:2379 \
  --initial-cluster-token etcd-cluster-token \
  --initial-cluster $THIS_CLUSTER \
  --initial-cluster-state new
