# harbor

Harbor is deployed by HelmRelease in this directory.

## Initial login

- Username: `admin`
- Password: `Harbor123`

After first login, change the admin password immediately.

## OIDC

OIDC is **not** managed by GitOps manifests in this folder.
Configure OIDC manually in Harbor UI:

1. `Administration` -> `Configuration` -> `Authentication`
2. Set `Auth Mode` to `OIDC`
3. Fill Logto endpoint/client credentials and group mapping as needed
