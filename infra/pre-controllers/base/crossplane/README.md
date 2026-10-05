# Crossplane management

This cluster follows CCSN's application-owned Logto/Harbor management model.
Git declares desired configuration, provider references and connection Secret
names. Providers allocate external resource IDs and record them in Kubernetes
annotations/status. External IDs are not pinned or written back to Git.

## Management policies

Policies match the corresponding upstream resources:

- Logto applications and named `GitOps` credentials use `Observe`, `Create`,
  `Update` and `LateInitialize`, except the shared Kubernetes application,
  which uses upstream's `Observe`, `Create` and `Update` policy.
- Harbor Registry, Project and robot resources use `Observe`, `Create` and
  `Update`. The ProxyCache definition supplies these defaults to its composition.
- Neither policy includes `Delete`.

There are no committed `crossplane.io/external-name` annotations, import ID
placeholders, additional resource pauses or suspended management layers.
Provider-assigned external IDs remain in Kubernetes across reconciliations.

## Credentials

The Logto Management API M2M credential is SOPS encrypted in
`apps/base/logto/management-credentials.yaml`, declaring
`Secret/prod/logto-management`. Edit it from the repository root:

```bash
SOPS_AGE_KEY_FILE=./k8s-gitops.agekey sops apps/base/logto/management-credentials.yaml
```

`stringData.credentials` is a JSON object containing `hostname`, `resource`,
`application_id` and `application_secret`. The M2M application must have Logto
Management API permissions. Keep real credentials out of the tracked example.
Harbor's SOPS-encrypted management credential is
`infra/configs/base/harbor/managed-resources/harbor-management.yaml`.

## Reconciliation and consumers

Provider packages and the Harbor definition/composition are installed after
Crossplane. The separate Logto release becomes ready before application identity
resources reconcile. These resources publish Kubernetes connection Secrets.

Grafana, Vaultwarden, OAuth2 Proxy, Harbor and Flux read client IDs and credentials
from their managed connection Secrets. Headlamp and Kiali obtain the shared
Kubernetes client ID through Flux substitution from its connection Secret.
A namespace-scoped gateway layer reads the OAuth2 Proxy connection Secret to
substitute its audience into the three existing gateway JWT policies. The old
Harbor Terraform resource is no longer included in reconciliation.

The API server is provisioned by isning/nix-config. Its OIDC client configuration
must use the provider-generated Kubernetes client ID; retrieve it using
`infra/configs/base/apiserver-oidc/README.md`. Node configuration is outside this
repository's reconciliation.

Crossplane remains a single replica. Local databases, Vaultwarden SQLite,
replica counts and RWO storage keep the homelab configuration.

The supplied M2M credential passed SOPS decrypt/MAC verification. Earlier
read-only discovery from this environment returned HTTP 403; access from the
cluster still requires runtime verification. No cluster deployment is performed
by repository validation.
