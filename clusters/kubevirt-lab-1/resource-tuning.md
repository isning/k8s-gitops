# Home single-node resource tuning

These settings apply only to the `home` cluster (`whitefox`). PVC sizes and
workspace data are deliberately unchanged.

## Cilium

The home overlay overrides `bpf.mapDynamicSizeRatio` from `0.08` to `0.01`.
Distributed LRU remains enabled. Before tuning, `bpftool map show` reported
about 9.48 GiB across the node's BPF maps, while the observed conntrack map
pressure was below 2%. These are point-in-time observations, not peak-load
measurements; check pressure under real workspace activity before further cuts.

`rollOutCiliumPods: true` ensures Helm config changes roll the agent and take
effect. BPF map resizing can reset existing connections. On a single node,
schedule future network changes for a maintenance window. Do not impose a small
hard memory limit on the networking agent as a substitute for map sizing.

## KubeVirt

The general-controller overlay sets `virt-operator` to one replica. The config
overlay sets `KubeVirt.spec.infra.replicas: 1`, allowing the operator itself to
reconcile virt-api, virt-controller and virt-exportproxy. Do not scale these
generated Deployments manually: the operator would restore its desired state.
Single replicas remove redundant same-node processes but provide no controller
redundancy. Revisit this override before adding more nodes.

## VictoriaMetrics cache budget

The home overlay sets `vmsingle.spec.extraArgs.memory.allowedBytes` to `512MiB`.
This bounds internal cache sizing, not total process memory. Existing process
limits, scrape intervals, retention and PVCs are unchanged. Smaller caches can
increase disk reads and CPU usage; revert this override if sustained cache
misses, query latency or ingestion backlog increase.

Use `MemTotal - MemAvailable` from the host's `/proc/meminfo` for before/after
comparisons under comparable workload. Pod working sets and BPF memlock totals
are not interchangeable with physical host memory savings. The initial host
baseline was approximately 15.5 GiB used; a 12 GiB target is not yet verified.
VictoriaMetrics was approximately 760 MiB RSS, and the host K3s service cgroup
approximately 3.6 GiB. K3s/NixOS configuration is not owned by this repository;
host-level tuning must be made in its configuration source, not a temporary
systemd override. Coder workspaces are deliberately excluded from tuning.

## Verification

```sh
kubectl --context home get --raw=/readyz
kubectl --context home -n kube-system get helmrelease cilium
kubectl --context home -n kube-system get pods -l k8s-app=cilium
kubectl --context home -n kubevirt get deployment
kubectl --context home -n kubevirt get kubevirt
kubectl --context home top node whitefox
```

On the current Cilium Pod, inspect `cilium-dbg status --brief`,
`cilium-dbg metrics list` (map pressure/capacity), and `bpftool -j map show`
(map allocation). Also verify external HTTPS, workspace access, public Service
addresses and Flux readiness after a rollout. Git provides the rollback: restore
the previous overlay values and reconcile Flux; never remove BPF maps manually.
