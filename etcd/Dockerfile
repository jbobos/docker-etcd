# Etcd cluster in Docker
#
# official base image
FROM gcr.io/etcd-development/etcd:v3.3.12

# install dependencies
RUN set -ex \
  && apk update \
  && apk add --no-cache dumb-init bind-tools \
  && rm -rf /var/cache/apk/*

# our custom entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["dumb-init", "entrypoint.sh"]
