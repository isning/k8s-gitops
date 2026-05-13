FROM ghcr.io/opentofu/opentofu:1.8.8 AS provider-mirror

WORKDIR /work
COPY tf/versions.tf ./versions.tf

RUN tofu init -backend=false -input=false -no-color \
    && mkdir -p /opt/tofu-providers \
    && tofu providers mirror /opt/tofu-providers

FROM ghcr.io/flux-iac/tf-runner:v0.16.3

COPY --from=provider-mirror /opt/tofu-providers /opt/tofu-providers
COPY tofu.rc /etc/tofu.rc
COPY tofu.rc /etc/terraform.rc
ENV TF_CLI_CONFIG_FILE=/etc/tofu.rc
