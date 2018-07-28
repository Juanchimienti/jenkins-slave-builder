FROM alpine:3.8

# Versions: https://pypi.python.org/pypi/awscli#downloads
ENV AWS_CLI_VERSION 1.15.66

ENV DOCKER_VERSION 18.03.1

USER root

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates groff \
                   less docker~${DOCKER_VERSION} git && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*
