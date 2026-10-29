# Paseo

Deploys the official Paseo daemon and web UI into `prod` at
`https://paseo.isning.moe`, through the existing `default-gateway`.
The image is pinned to version `0.11.1` and its multi-platform manifest digest.

An init container installs these fixed CLI versions into a shared `emptyDir`:

- Codex `0.161.0`
- Claude Code `2.1.294`
- Pi `1.1.0` (`@earendil-works/pi-coding-agent`)

The init container uses the same image, verifies each CLI with `--version`, and
must finish successfully before Paseo starts. Each new Pod installs the CLIs;
the npm download cache persists in the home volume. Top-level versions are
pinned; npm resolves transitive dependencies during installation.

The Pod runs as UID/GID `1000` under the existing `gvisor` RuntimeClass, without
a Kubernetes API token. Both containers drop capabilities and use a read-only
root filesystem. Agent installations are read-only in the main container.

Two persistent volumes store home state and credentials (5 GiB at `/home/paseo`)
and repositories (20 GiB at `/workspace`). `Recreate` avoids concurrent writers
on the ReadWriteOnce volumes. Temporary files use a bounded `emptyDir`.

The required `PASEO_PASSWORD` is generated and SOPS-encrypted in `secret.yaml`
with the repository's existing age recipient. Provider credentials are not
included. Authenticate Codex, Claude Code, and Pi using their login commands
inside the container after deployment; their configuration persists in the home
volume. Repository access also needs the appropriate Git credentials.

The HTTPRoute forwards HTTP and WebSocket traffic to port `6767`.
`PASEO_HOSTNAMES` allows the public hostname. Startup, readiness, and liveness
probes use the image's documented `/api/health` endpoint.

This application runs its providers inside the Paseo Pod; it does not create
Agent Sandbox claims or dispatch provider processes to separate sandbox Pods.

References:

- [Official container documentation](https://github.com/getpaseo/paseo/blob/v0.11.1/docs/docker.md)
- [Pi installation](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/README.md)
