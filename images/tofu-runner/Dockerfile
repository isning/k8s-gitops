FROM ghcr.io/flux-iac/tf-runner:v0.16.3@sha256:b8632592cd6674517e36cb412c856cdc77c3a6f6b16e42af030f683f16178d99

USER root

WORKDIR /tmp
COPY --from=repo tf/versions.tf ./versions.tf
COPY tofu.rc /etc/tofu.rc
COPY tofu.rc /etc/terraform.rc

RUN tofu init -backend=false -input=false -no-color \
    && mkdir -p /opt/tofu-providers \
    && tofu providers mirror /opt/tofu-providers \
    && rm -rf /tmp/.terraform /tmp/.terraform.lock.hcl /tmp/versions.tf

ENV TF_CLI_CONFIG_FILE=/etc/tofu.rc
USER 65532:65532
