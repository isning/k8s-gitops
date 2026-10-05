# Crossplane management adoption

This overlay adds single-replica Crossplane and the pinned Logto/Harbor providers.
Existing application identities, Harbor projects and the Kubernetes robot must
be imported by their existing external IDs. Application replicas, databases and
storage classes retain the homelab settings.

The cluster has three management reconciliation stages:

1. `management-providers` installs provider packages and the Harbor ProxyCache
   definition/composition after Crossplane is available.
2. `management-configs` installs provider credentials and Harbor resource imports.
   It is initially suspended because Harbor IDs still need to be supplied.
3. `identity-applications` observes existing Logto applications and their named
   secrets. It is initially suspended until management credentials and import
   mappings are verified.

All resource imports start with `Observe`, without create or delete permission.
The old Terraform entrypoints and existing application Secrets remain available
through the adoption phase. The separate managed connection Secrets allow
comparison before changing any consumer. No cluster changes are performed by
this repository update.

## Fill the Logto credentials

Edit the encrypted file directly, from the repository root:

```bash
SOPS_AGE_KEY_FILE=./k8s-gitops.agekey sops apps/base/logto/management-credentials.yaml
```

The file declares `Secret/prod/logto-management`; `stringData.credentials` is a
JSON object. Replace `application_id` and `application_secret` with an M2M
application authorized for the Logto Management API. Verify that `resource`
matches the Management API resource in this Logto instance. `hostname` excludes
the URL scheme. Keep the existing Secret name and JSON property names.

`management-credentials.yaml.example` documents the format with placeholders.
Do not paste real credentials into that tracked example or a command line.
Harbor credentials are already SOPS encrypted in
`infra/configs/base/harbor/managed-resources/harbor-management.yaml`.

## Import the existing resources

Before enabling the suspended layers, replace the public ID placeholders:

- `infra/configs/base/harbor/managed-resources/proxy-caches.yaml`: existing registry
  ID (`spec.registry.externalID`) and project ID (`spec.projectID`) for each of
  the seven locally configured proxy projects. Obtain the IDs from the existing
  Terraform state or Harbor's API. Preserve registry adapters and existing names.
- `infra/configs/base/harbor/managed-resources/robot.yaml`: the existing `k8s`
  system robot ID in `crossplane.io/external-name`. Its password output uses the
  existing `harbor-k8s-robot-account-auth` Secret.
- `infra/configs/base/flux/identity/oidc-application.yaml`: the existing Flux Web
  client ID. This application is individually paused until the ID is filled.
- Each `identity/oidc-credential.yaml`: the existing Logto named secret. Import
  IDs use `<application-id>/<secret-name>`. These resources are individually
  paused to avoid rotating or replacing existing credentials. Confirm the name
  in Logto rather than assuming that it is `default`.

The other Application external IDs were preserved from the local configuration.
For Kubernetes, both API server authentication and Headlamp keep the shared
application. There are no imported upstream business roles or identity providers.

Remove `crossplane.io/paused` only from resources with verified IDs. Unsuspend
`management-configs`, verify provider/resource readiness, then unsuspend
`identity-applications`. Check observed external IDs and generated connection
Secrets against current consumers before proceeding. Never enable `Create` to
work around a failed import.

## Transfer ownership

After the observe phase is healthy, suspend the existing Harbor Terraform
reconciliation. Compare each observed resource with its desired local spec, then
permit `Observe` and `Update` on the corresponding resources (and the
ProxyCache `resourceManagementPolicies`). Keep `Delete` disabled while validating
adoption. Logto resource creation is deliberately disabled for existing clients.

Change each application's existing credential wiring only after the managed
Secret has the expected client ID and secret. Logto provider connection keys are
`clientId`/`clientSecret`; adapt consumers explicitly instead of renaming old
Secrets in place. Remove the old Harbor Terraform entrypoint/tofu controller only
after all users of it have transferred ownership successfully. This staged
handoff prevents losing the current robot account or login sessions when the
new provider is not yet authenticated.

Reference: [Crossplane imports](https://docs.crossplane.io/latest/guides/import-existing-resources/).

## Validation boundary for this PR

The supplied Logto credentials are SOPS encrypted and passed a decrypt/MAC
round-trip check. Read-only discovery through the public Logto and Harbor
endpoints returned HTTP 403 from this environment, so API authentication and
external resource IDs could not be verified here. This does not establish that
the credentials are invalid. Keep the two adoption layers suspended until
discovery is possible from an allowed network and IDs are supplied.

The proxy change replaces a Deployment with a single-replica StatefulSet while
retaining the existing RWO nodes cache. Expect a short service interruption
during workload replacement; verify volume attachment and proxy readiness.
The retired work-cache PVC has pruning disabled so its data is retained.
