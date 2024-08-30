FROM alpine:3.20

# Versions: https://pypi.python.org/pypi/awscli#downloads
ENV AWS_CLI_VERSION 1.29.85

# Aws Elastic Beanstalk CLI https://github.com/aws/aws-elastic-beanstalk-cli/tags
ENV EB_VERSION="3.20.10"

ENV DOCKER_VERSION 26

USER root

RUN apk --no-cache update \
    && apk --no-cache add python3 py-pip py-setuptools ca-certificates groff bash rsync\
                   less docker~${DOCKER_VERSION} git gcc libffi-dev python3-dev musl-dev \
    && pip install --break-system-packages --no-cache-dir --ignore-installed awscli==${AWS_CLI_VERSION} awsebcli==${EB_VERSION} six \
    && rm -rf /var/cache/apk/*

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.21.11"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION_3="v3.5.2"
# Note: Latest version of helm diff plugin cat be found at:
# https://github.com/databus23/helm-diff/releases
ENV HELM_DIFF_VERSION_3="v3.1.3"

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-${HELM_VERSION_3}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm3 \
    && ln -sf /usr/local/bin/helm3 /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm3 \
    && helm3 plugin install 'https://github.com/databus23/helm-diff' --version ${HELM_DIFF_VERSION_3}

ENV SOPS_VERSION="v3.7.3"

RUN wget https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux -O /usr/local/bin/sops \
   && chmod +x /usr/local/bin/sops

ARG CLOUD_SDK_VERSION=490.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && ln -s /lib /lib64 \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud config set metrics/environment github_docker_image \
    && gcloud --version

