# Magpie

Magpie replaces the Metapi gateway without importing its data. Configure providers,
models, routing and gateway keys manually in the dashboard after deployment.

- Dashboard: `https://llm-dash.isning.moe`, authenticated by the existing gateway
  OAuth provider. Any user accepted by that OAuth provider can administer Magpie.
- API: `https://llm.isning.moe/v1` (also `/v1beta` and `/mcp`), authenticated by
  Magpie gateway keys. Create an enabled key in the dashboard before using clients.
- Persistent state: the independent `magpie-config` PVC mounted at `/config`.
  Flux pruning is disabled for this PVC. Back it up before deleting the PVC itself.

## Browser authentication

The pinned official image requires a Web key and does not support disabling it.
An init container generates a random key in a memory-backed volume shared only
inside the Pod. Magpie's Web listener binds to loopback, and the nginx sidecar
injects the matching cookie after gateway OAuth authentication. Users neither
enter nor manage that key. The sidecar hides upstream sign-in cookies, rejects
Web key sign-in requests and requires the dashboard Origin for mutations, since
injecting the cookie would otherwise remove the application's CSRF protection.
The ingress NetworkPolicy permits only the production gateway to reach the Pod.
The API listener continues to require a Magpie gateway key; proxy trust is not
enabled. The ephemeral Web key changes when the Pod is replaced.

The sidecar depends on Magpie's `magpie_web_3430` cookie name. Check this contract
when upgrading Magpie. Both images are pinned by digest. The read-only root
filesystem prevents the application from replacing the pinned binary itself.

## Cutover and rollback

The HTTPRoutes retain the names `metapi-route` and `metapi-api` to update the
existing domain routes without creating competing routes. They are now owned by
this Kustomization. Metapi remains in the production overlay at zero replicas,
with its Secret and PVC retained. Its old HTTPRoute file is inactive.

Validate with:

```bash
kubectl kustomize apps/overlays/kubevirt-lab-1/prod > /dev/null
kubectl apply --dry-run=server -n prod -k apps/base/magpie
kubectl -n prod rollout status deployment/magpie --timeout=120s
```

For rollback, restore Metapi's replica count to one, remove Magpie's HTTPRoutes
from its resources, and restore `httproute.yaml` to Metapi's resources in Git.
Apply the change through the normal Flux workflow. Do not delete either data PVC.
Existing Metapi clients' keys are not imported; provision Magpie gateway keys and
configure their models before expecting inference calls to work.

For subscription sign-in callbacks that redirect to a browser's localhost,
paste the complete callback URL into Magpie's callback field as described in the
[upstream Docker documentation](https://github.com/yetone/magpie/blob/main/docs/reference.md#docker).
