# Crossplane management

This cluster follows CCSN's application-owned Logto/Harbor management model.
Git declares desired configuration, provider references and connection Secret
names. During adoption, existing external resource IDs are bound manually in
Kubernetes annotations. Providers allocate IDs for new resources and record them
in Kubernetes annotations/status. External IDs are not pinned or written back to Git.

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
External resource IDs remain in Kubernetes across reconciliations.

## Manual adoption

Before reconciling existing resources, match the live Logto application IDs to
the client IDs used by each current consumer. Create each Application CR with
its `crossplane.io/external-name` annotation in the same Kubernetes API operation.
Keep the upstream management policies unchanged. Import an existing named
`GitOps` credential if present; otherwise create that additional credential
without replacing the legacy credential.

For Harbor, suspend the legacy Terraform reconciliation before the ownership
handoff. Match each existing proxy-cache project to its registry, then create
the Registry and Project CRs with their runtime external-name bindings. A
temporary runtime pause on the ProxyCache prevents its composition from racing
with adoption. Attach the composed resource references and owner references
before removing that pause. Bind the existing system robot account as well.

Verify Ready/Synced conditions and connection Secrets before switching consumers.
These adoption annotations, temporary pauses and external IDs belong only in
Kubernetes. Do not copy them into repository manifests.

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
must use the managed Kubernetes client ID; retrieve it using
`infra/configs/base/apiserver-oidc/README.md`. Node configuration is outside this
repository's reconciliation. Adopting the existing shared Kubernetes application
preserves its client ID and avoids an API-server OIDC configuration change.

Crossplane remains a single replica. Local databases, Vaultwarden SQLite,
replica counts and RWO storage keep the homelab configuration.

The supplied M2M credential passed SOPS decrypt/MAC verification and read-only
Management API discovery through the existing Logto service. Runtime adoption
and provider reconciliation are separate from repository validation.
