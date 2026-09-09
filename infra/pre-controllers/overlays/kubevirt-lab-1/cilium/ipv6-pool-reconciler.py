#!/usr/bin/env python3
"""Keep the Cilium public LB pool inside the node's current delegated IPv6 prefix."""

import ipaddress
import json
import os
import ssl
import time
import urllib.request
from datetime import UTC, datetime


API = "https://kubernetes.default.svc"
TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CA_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
NOTIFIED_CIDR_ANNOTATION = "networking.isning.moe/edgeone-notified-cidr"


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
            "Content-Type": "application/merge-patch+json",
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


def node_internal_ips():
    nodes = request("/api/v1/nodes")
    return [
        address["address"]
        for node in nodes.get("items", [])
        for address in node.get("status", {}).get("addresses", [])
        if address.get("type") == "InternalIP"
    ]


def services_use_prefix(prefix):
    services = request("/api/v1/services")
    public_ipv6 = []
    for service in services.get("items", []):
        if service.get("spec", {}).get("type") != "LoadBalancer":
            continue
        for ingress in service.get("status", {}).get("loadBalancer", {}).get("ingress", []):
            value = ingress.get("ip")
            if value:
                address = ipaddress.ip_address(value)
                if isinstance(address, ipaddress.IPv6Address) and address.is_global:
                    public_ipv6.append(address)
    return public_ipv6 and all(address in prefix for address in public_ipv6)


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
    pool_name = os.environ["POOL_NAME"]
    desired = desired_pool_cidr(node_internal_ips(), os.environ["POOL_SUBNET_HEXTET"])
    path = f"/apis/cilium.io/v2/ciliumloadbalancerippools/{pool_name}"
    pool = request(path)
    current = [block.get("cidr") for block in pool.get("spec", {}).get("blocks", [])]
    notified = pool.get("metadata", {}).get("annotations", {}).get(NOTIFIED_CIDR_ANNOTATION)
    if current != [str(desired)]:
        request(path, "PATCH", {"spec": {"blocks": [{"cidr": str(desired)}]}})
        print(f"Updated {pool_name}: {current} -> {desired}", flush=True)
    deadline = time.monotonic() + 180
    while time.monotonic() < deadline:
        if services_use_prefix(desired.supernet(new_prefix=64)):
            print(f"All public LoadBalancer IPv6 addresses use {desired.supernet(new_prefix=64)}", flush=True)
            if notified != str(desired):
                notify_edgeone(path, desired)
            return
        time.sleep(5)
    raise TimeoutError("LoadBalancer Services did not move to the current IPv6 prefix")


if __name__ == "__main__":
    main()
