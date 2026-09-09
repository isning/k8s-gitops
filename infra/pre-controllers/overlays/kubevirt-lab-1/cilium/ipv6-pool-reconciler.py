#!/usr/bin/env python3
"""Keep the Cilium public LB pool inside the node's current delegated IPv6 prefix."""

import argparse
import ipaddress
import json
import os
import ssl
import socket
import time
import urllib.request
from urllib.error import HTTPError
from datetime import UTC, datetime


API = "https://kubernetes.default.svc"
TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CA_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
NOTIFIED_CIDR_ANNOTATION = "networking.isning.moe/edgeone-notified-cidr"
OWNER_ANNOTATION = "networking.isning.moe/managed-by"
OWNER = "ipv6-pool-reconciler"
POOL_COLLECTION = "/apis/cilium.io/v2/ciliumloadbalancerippools"


def request(path, method="GET", body=None):
    with open(TOKEN_PATH, encoding="utf-8") as token_file:
        token = token_file.read().strip()
    data = None if body is None else json.dumps(body, separators=(",", ":")).encode()
    req = urllib.request.Request(
        f"{API}{path}",
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/json",
            "Content-Type": "application/merge-patch+json" if method == "PATCH" else "application/json",
        },
    )
    with urllib.request.urlopen(req, context=ssl.create_default_context(cafile=CA_PATH), timeout=30) as response:
        return json.load(response)


def desired_pool_cidr(addresses, subnet_hextet):
    prefixes = {
        ipaddress.IPv6Network((address, 64), strict=False)
        for address in map(ipaddress.ip_address, addresses)
        if isinstance(address, ipaddress.IPv6Address) and address.is_global
    }
    if len(prefixes) != 1:
        raise RuntimeError(f"expected one global node IPv6 /64, found {sorted(map(str, prefixes))}")
    prefix = prefixes.pop()
    subnet = int(subnet_hextet, 16)
    if not 0 <= subnet <= 0xFFFF:
        raise RuntimeError("POOL_SUBNET_HEXTET must be one IPv6 hextet")
    return ipaddress.IPv6Network((int(prefix.network_address) | (subnet << 48), 112))


def validate_source(source, interface, interface_addresses):
    """Require the route-selected address to be usable on the configured uplink."""
    source = ipaddress.IPv6Address(source)
    if not source.is_global:
        raise RuntimeError("route-selected IPv6 source is not global")
    for line in interface_addresses.splitlines():
        address, _, prefix_length, _, flags, name = line.split()
        if name != interface or ipaddress.IPv6Address(int(address, 16)) != source:
            continue
        # Linux IFA_F_OPTIMISTIC, DADFAILED, DEPRECATED and TENTATIVE.
        if int(flags, 16) & 0x6C:
            raise RuntimeError("route-selected IPv6 source is not preferred/usable")
        if int(prefix_length, 16) != 64:
            raise RuntimeError("uplink IPv6 prefix must be /64")
        return str(source)
    raise RuntimeError(f"route-selected IPv6 source is not on {interface}")


def host_ipv6_source():
    # UDP connect performs a local route lookup; no packet is sent.
    target = str(ipaddress.IPv6Address(os.environ["IPV6_ROUTE_TARGET"]))
    with socket.socket(socket.AF_INET6, socket.SOCK_DGRAM) as probe:
        probe.connect((target, 53))
        source = probe.getsockname()[0]
    with open("/proc/net/if_inet6", encoding="ascii") as addresses:
        return validate_source(source, os.environ["IPV6_INTERFACE"], addresses.read())


def ensure_pool(pool_name, desired, check=False):
    """Create or reconcile our pool only; adoption must be explicitly authorized."""
    path = f"{POOL_COLLECTION}/{pool_name}"
    spec = {"allowFirstLastIPs": "No", "blocks": [{"cidr": str(desired)}],
            "disabled": False, "serviceSelector": {}}
    try:
        pool = request(path)
    except HTTPError as error:
        if error.code != 404:
            raise
        if check:
            print(f"Would create {pool_name}: {desired}", flush=True)
            return None
        pool = request(POOL_COLLECTION, "POST", {
            "apiVersion": "cilium.io/v2", "kind": "CiliumLoadBalancerIPPool",
            "metadata": {"name": pool_name, "annotations": {
                OWNER_ANNOTATION: OWNER, "kustomize.toolkit.fluxcd.io/prune": "disabled",
            }}, "spec": spec,
        })
        print(f"Created {pool_name}: {desired}", flush=True)
    annotations = pool.get("metadata", {}).get("annotations", {})
    if annotations.get(OWNER_ANNOTATION) != OWNER:
        raise RuntimeError(f"refusing to adopt unowned pool {pool_name}")
    flux_labels = {key: None for key in pool.get("metadata", {}).get("labels", {})
                   if key in ("kustomize.toolkit.fluxcd.io/name", "kustomize.toolkit.fluxcd.io/namespace")}
    if flux_labels and not check:
        request(path, "PATCH", {"metadata": {"labels": flux_labels}})
    actual = pool.get("spec", {})
    normalized = {"disabled": False, "serviceSelector": {}, **actual}
    if any(normalized.get(key) != value for key, value in spec.items()):
        if not check:
            # Clear old selector keys as well: the generated pool owns this entire spec.
            request(path, "PATCH", {"spec": {**spec, "serviceSelector": None}})
        print(f"{'Would update' if check else 'Updated'} {pool_name}: {desired}", flush=True)
    return annotations.get(NOTIFIED_CIDR_ANNOTATION)


def services_use_prefix(prefix):
    services = request("/api/v1/services")
    public_ipv6 = []
    for service in services.get("items", []):
        if service.get("spec", {}).get("type") != "LoadBalancer":
            continue
        if "IPv6" not in service.get("spec", {}).get("ipFamilies", []):
            continue
        assigned = []
        for ingress in service.get("status", {}).get("loadBalancer", {}).get("ingress", []):
            value = ingress.get("ip")
            if value:
                address = ipaddress.ip_address(value)
                if isinstance(address, ipaddress.IPv6Address) and address.is_global:
                    assigned.append(address)
        if not assigned:
            return False
        public_ipv6.extend(assigned)
    return bool(public_ipv6) and all(address in prefix for address in public_ipv6)


def notify_edgeone(pool_path, desired):
    namespace = os.environ["EDGEONE_TERRAFORM_NAMESPACE"]
    name = os.environ["EDGEONE_TERRAFORM_NAME"]
    terraform_path = (
        "/apis/infra.contrib.fluxcd.io/v1alpha2/namespaces/"
        f"{namespace}/terraforms/{name}"
    )
    requested_at = datetime.now(UTC).isoformat(timespec="seconds").replace("+00:00", "Z")
    request(
        terraform_path,
        "PATCH",
        {"metadata": {"annotations": {"reconcile.fluxcd.io/requestedAt": requested_at}}},
    )
    request(
        pool_path,
        "PATCH",
        {"metadata": {"annotations": {NOTIFIED_CIDR_ANNOTATION: str(desired)}}},
    )
    print(f"Requested {namespace}/{name} reconciliation for {desired}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", choices=["detect", "pool", "all"], default="all")
    parser.add_argument("--check", action="store_true", help="Show the pool plan without any API writes")
    args = parser.parse_args()
    pool_name = os.environ["POOL_NAME"]
    desired = desired_pool_cidr([host_ipv6_source()], os.environ["POOL_SUBNET_HEXTET"])
    print(f"Detected host pool CIDR: {desired}", flush=True)
    if args.stage == "detect":
        return
    path = f"{POOL_COLLECTION}/{pool_name}"
    notified = ensure_pool(pool_name, desired, check=args.check)
    if args.check or args.stage == "pool":
        return
    deadline = time.monotonic() + 180
    while time.monotonic() < deadline:
        if services_use_prefix(desired):
            print(f"All public LoadBalancer IPv6 addresses use {desired}", flush=True)
            if notified != str(desired):
                notify_edgeone(path, desired)
            return
        time.sleep(5)
    raise TimeoutError("LoadBalancer Services did not move to the current IPv6 prefix")


if __name__ == "__main__":
    main()
