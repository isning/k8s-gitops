# Dynamic public IPv6 pool

`ipv6-pool-reconciler` keeps Cilium's public LoadBalancer pool under the
single node's current global IPv6 `/64`. It reserves the `caf0` subnet and
publishes it as a `/112` pool.

The CronJob runs every five minutes and performs these steps:

1. read the global IPv6 `InternalIP` advertised by the Kubernetes Node;
2. derive `<current-/64>:caf0::/112`;
3. patch `default-public-ipv6-pool` only when that CIDR changed;
4. wait until Cilium has reallocated every public IPv6 LoadBalancer address.

ExternalDNS and the EdgeOne Terraform controllers consume Service status, so
they update DNS and EdgeOne origins after Cilium finishes reallocating. The
pool manifest uses Flux's `IfNotPresent` apply policy: Git provides the initial
bootstrap object, while the reconciler owns its changing CIDR afterwards.

The job deliberately fails if Nodes expose different public `/64` prefixes.
That prevents silently choosing the wrong uplink if the cluster later becomes
multi-node.
