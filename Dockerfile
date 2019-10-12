# etcd with Docker compose
#
# official base image
FROM gcr.io/etcd-development/etcd:v3.3.12

# Our custom entrypoint will generate etcd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start etcd use the generated configuration file
CMD ["etcd", "--config-file", "/etc/etcd.conf"]
