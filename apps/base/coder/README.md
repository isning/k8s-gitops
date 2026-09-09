# Coder

This deploys Coder 2.34.7 with a single-instance CNPG PostgreSQL 16 database, CNPG barman-cloud
backups to the existing Cloudflare R2 endpoint, Gateway API routing, OIDC via Logto,
and VictoriaMetrics scraping for both Coder and PostgreSQL.

Before syncing the `prod` overlay:

1. In Logto, create a traditional web application named `Coder`.
2. Set redirect URI to `https://coder.isning.moe/api/v2/users/oidc/callback`.
3. Enable scopes `openid`, `profile`, `email`, `offline_access`, and `roles`.
4. Run `sops apps/base/coder/oidc-secret.yaml`, replace both encrypted placeholder
   values, and save the file.
5. Connect `isning.moe` to an EdgeOne site in CNAME mode and note its zone ID.
6. Run `sops apps/base/coder/edgeone-secret.yaml`, then replace the zone ID and the
   Tencent Cloud API credentials. Grant that identity only the TEO permissions needed
   by the Tofu resources plus `ApplyFreeCertificate`,
   `CheckFreeCertificateVerification`, and `ModifyHostsCertificate` for certificate
   issuance and deployment.

`coder.isning.moe` uses the existing Cloudflare Tunnel and `default-gateway` path.
Workspace applications use a dedicated IPv6-only `coder-gateway`. Its origin address
must not be published through ExternalDNS: doing so would expose the origin and allow
traffic to bypass EdgeOne. EdgeOne should receive the current LoadBalancer IPv6 address
directly through its API, while public wildcard DNS points only to EdgeOne.

Two Tofu states and an ephemeral certificate reconciler implement that ordering.
`coder-edgeone-control` reads the IPv6 address from the Istio-generated
`coder-gateway-istio` Service, configures the EdgeOne wildcard acceleration domain,
then writes only the assigned EdgeOne CNAME to a Kubernetes Secret.
`coder-edgeone-sync` publishes `*.coder.isning.moe` as that EdgeOne CNAME through
ExternalDNS. Public DNS therefore exposes the EdgeOne endpoint rather than retaining
the origin IPv6 address. Origin Protection is not required by this deployment. The
sync state still observes EdgeOne's current and pending origin IPv6 ranges. When the
API returns a non-empty list, it installs a Cilium allow policy for those ranges; an
empty list leaves the Gateway unfiltered rather than blocking all EdgeOne traffic.

The `coder-edgeone-certificate` CronJob waits for both Tofu states to become Ready,
requests EdgeOne DNS-delegated validation for the wildcard certificate, and publishes
the returned `_acme-challenge` CNAME through a separate ExternalDNS `DNSEndpoint`.
After EdgeOne confirms validation, it deploys the certificate with
`eofreecert_manual`. The delegation record remains in Cloudflare so EdgeOne can renew
the certificate automatically. Interrupted orders are resumed for up to 48 hours;
only stale orders are replaced. The CronJob runs daily for reconciliation and creates
no permanently running pod.

The apex `coder.isning.moe` remains on the existing Cloudflare Tunnel and
`default-gateway`; neither its DNS path nor the global Gateway is changed.

The backup ObjectStore reuses the existing `logto-pg-s3-credentials` Secret and stores
backups beneath the `coder/` prefix in the existing `logto-pg-backup` bucket. Both are
already managed in the `prod` namespace by the Logto base.

Coder's control plane runs in `prod`, while workspace pods and PVCs should use the
dedicated `coder` namespace. The chart grants its service account workspace permissions
only in that namespace; set `namespace = "coder"` in Kubernetes-based Coder templates.

Group and role synchronization are intentionally not enabled because they require a
Coder enterprise license. Basic OIDC login works with the open-source deployment.
