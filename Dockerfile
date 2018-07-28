FROM alpine:3.8

# Versions: https://pypi.python.org/pypi/awscli#downloads
ENV AWS_CLI_VERSION 1.15.66

# Versions: https://github.com/docker/docker-ce/releases
ENV DOCKER_VERSION 18.03.1

USER root

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates groff \
                   less docker~${DOCKER_VERSION} git && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.10.6"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.9.1"

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm
