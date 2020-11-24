FROM alpine:3.11

# Versions: https://pypi.python.org/pypi/awscli#downloads
ENV AWS_CLI_VERSION 1.18.127

# Versions: https://github.com/docker/docker-ce/releases
ENV DOCKER_VERSION 19

USER root

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates groff bash \
                   less docker~${DOCKER_VERSION} git && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.14.10"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.17.0"
# Note: Latest version of helm diff plugin cat be found at:
# https://github.com/databus23/helm-diff/releases
ENV HELM_DIFF_VERSION="v2.9.0+3"

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm init --client-only \
    && helm plugin install 'https://github.com/databus23/helm-diff' --version ${HELM_DIFF_VERSION}

ENV SOPS_VERSION="v3.5.0"

RUN wget https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux -O /usr/local/bin/sops \
   && chmod +x /usr/local/bin/sops

ARG CLOUD_SDK_VERSION=237.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

# Aws Elastic Beanstalk CLI
ENV EB_VERSION="3.15.2"
RUN pip --no-cache-dir install awsebcli==${EB_VERSION}
