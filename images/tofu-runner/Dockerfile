FROM ghcr.io/opentofu/opentofu:1.11.7@sha256:6166f12d09520dbbb431a13951973c5b1046c01f801fa8c7b73e89511a0fff34 AS provider-mirror

WORKDIR /work
COPY --from=repo tf/versions.tf ./versions.tf

RUN tofu init -backend=false -input=false -no-color \
    && mkdir -p /opt/tofu-providers \
    && tofu providers mirror /opt/tofu-providers

FROM ghcr.io/flux-iac/tf-runner:v0.16.3@sha256:b8632592cd6674517e36cb412c856cdc77c3a6f6b16e42af030f683f16178d99

COPY --from=provider-mirror /opt/tofu-providers /opt/tofu-providers
COPY tofu.rc /etc/tofu.rc
COPY tofu.rc /etc/terraform.rc
ENV TF_CLI_CONFIG_FILE=/etc/tofu.rc
