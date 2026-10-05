This should cooperate with https://github.com/isning/nix-config/commit/438ed686e10ff3641cd977296b5d58f343c7daa9

For login: 
```sh
oidc_client_id="$(kubectl -n flux-system get secret kubernetes-cluster-managed-application -o jsonpath='{.data.clientId}' | base64 --decode)"
kubectl oidc-login setup --oidc-issuer-url=https://logto.isning.moe/oidc --oidc-client-id="$oidc_client_id" --oidc-extra-scope profile,roles
```

Use the same runtime client ID in the API server's OIDC configuration in
isning/nix-config. External application IDs are assigned by the provider and
remain in Kubernetes; do not pin them in Git.

Reference: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-authentication-configuration
