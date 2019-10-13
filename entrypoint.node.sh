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

# https://github.com/etcd-io/etcd/blob/master/etcd.conf.yml.sample
cat >>/etc/etcd.conf <<EOF
# This is the configuration file for the etcd server.

# Human-readable name for this member.
name: $THIS_NAME

# Path to the data directory.
data-dir: /etcd-data/$THIS_NAME

# Path to the dedicated wal directory.
wal-dir:

# Number of committed transactions to trigger a snapshot to disk.
snapshot-count: 10000

# Time (in milliseconds) of a heartbeat interval.
heartbeat-interval: 100

# Time (in milliseconds) for an election to timeout.
election-timeout: 1000

# Raise alarms when backend size exceeds the given quota. 0 means use the
# default quota.
quota-backend-bytes: 0

# List of comma separated URLs to listen on for peer traffic.
listen-peer-urls: http://0.0.0.0:2380

# List of comma separated URLs to listen on for client traffic.
listen-client-urls: http://0.0.0.0:2379

# Maximum number of snapshot files to retain (0 is unlimited).
max-snapshots: 5

# Maximum number of wal files to retain (0 is unlimited).
max-wals: 5

# Comma-separated white list of origins for CORS (cross-origin resource sharing).
cors:

# List of this member's peer URLs to advertise to the rest of the cluster.
# The URLs needed to be a comma-separated list.
initial-advertise-peer-urls: http://$THIS_IP:2380

# List of this member's client URLs to advertise to the public.
# The URLs needed to be a comma-separated list.
advertise-client-urls: http://$THIS_IP:2379

# Discovery URL used to bootstrap the cluster.
discovery:

# Valid values include 'exit', 'proxy'
discovery-fallback: 'proxy'

# HTTP proxy to use for traffic to discovery service.
discovery-proxy:

# DNS domain used to bootstrap initial cluster.
discovery-srv:

# Initial cluster configuration for bootstrapping.
initial-cluster: $THIS_CLUSTER

# Initial cluster token for the etcd cluster during bootstrap.
initial-cluster-token: 'etcd-cluster'

# Initial cluster state ('new' or 'existing').
initial-cluster-state: 'new'

# Reject reconfiguration requests that would cause quorum loss.
strict-reconfig-check: false

# Accept etcd V2 client requests
enable-v2: true

# Enable runtime profiling data via HTTP server
enable-pprof: true

# Valid values include 'on', 'readonly', 'off'
proxy: 'off'

# Time (in milliseconds) an endpoint will be held in a failed state.
proxy-failure-wait: 5000

# Time (in milliseconds) of the endpoints refresh interval.
proxy-refresh-interval: 30000

# Time (in milliseconds) for a dial to timeout.
proxy-dial-timeout: 1000

# Time (in milliseconds) for a write to timeout.
proxy-write-timeout: 5000

# Time (in milliseconds) for a read to timeout.
proxy-read-timeout: 0

client-transport-security:
  # Path to the client server TLS cert file.
  cert-file:

  # Path to the client server TLS key file.
  key-file:

  # Enable client cert authentication.
  client-cert-auth: false

  # Path to the client server TLS trusted CA cert file.
  trusted-ca-file:

  # Client TLS using generated certificates
  auto-tls: false

peer-transport-security:
  # Path to the peer server TLS cert file.
  cert-file:

  # Path to the peer server TLS key file.
  key-file:

  # Enable peer client cert authentication.
  client-cert-auth: false

  # Path to the peer server TLS trusted CA cert file.
  trusted-ca-file:

  # Peer TLS using generated certificates.
  auto-tls: false

# Enable debug-level logging for etcd.
debug: false

logger: zap

# Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
log-outputs: [stderr]

# Force to create a new one member cluster.
force-new-cluster: false

auto-compaction-mode: periodic
auto-compaction-retention: "1"
EOF

# start etcd use the generated configuration file
etcd --config-file /etc/etcd.conf
