# Etcd cluster in Docker

## Quick start
```bash
# start a static etcd cluster with 3 nodes
docker-compose up -d --scale etcd=3
# check logs
docker-compose logs -f etcd
```

## Testing
```bash
# If using released versions earlier than v3.4, set ETCDCTL_API=3 to use v3 API.
# See https://github.com/etcd-io/etcd/tree/master/etcdctl
$ export ETCDCTL_API=3

# Use `docker network inspect docker-etcd_net_etcd` to find all containers' ip
$ ENDPOINTS=172.18.0.2:2379,172.18.0.3:2379,172.18.0.4:2379

# check cluster status
$ etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status
+-----------------+------------------+---------+---------+-----------+-----------+------------+
|    ENDPOINT     |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+-----------------+------------------+---------+---------+-----------+-----------+------------+
| 172.18.0.2:2379 | 402ff265b80d4dc1 |  3.3.12 |   20 kB |      true |         2 |          8 |
| 172.18.0.3:2379 | b063ce376278837c |  3.3.12 |   20 kB |     false |         2 |          8 |
| 172.18.0.4:2379 | daa53193d66b358f |  3.3.12 |   20 kB |     false |         2 |          8 |
+-----------------+------------------+---------+---------+-----------+-----------+------------+
```

## Environment
```bash
$ cat /etc/redhat-release
CentOS Linux release 7.7.1908 (Core)

$ docker --version
Docker version 1.13.1, build 7f2769b/1.13.1

$ docker-compose --version
docker-compose version 1.24.1, build 4667896b

$ docker images --format "{{.Repository}}:{{.Tag}}"
gcr.io/etcd-development/etcd:v3.3.12
```

## Reference
- https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md#static
- https://github.com/etcd-io/etcd/blob/master/Documentation/demo.md
