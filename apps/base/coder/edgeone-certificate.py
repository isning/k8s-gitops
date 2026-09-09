#!/usr/bin/env python3
"""Reconcile EdgeOne wildcard certificate DNS delegation through ExternalDNS."""

from __future__ import annotations

import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone
from typing import Any


NAMESPACE = os.getenv("POD_NAMESPACE", "prod")
KUBERNETES_HOST = os.getenv("KUBERNETES_SERVICE_HOST", "kubernetes.default.svc")
KUBERNETES_PORT = os.getenv("KUBERNETES_SERVICE_PORT_HTTPS", "443")
KUBERNETES_API = f"https://{KUBERNETES_HOST}:{KUBERNETES_PORT}"
TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CA_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
ORDER_CREATED_AT_ANNOTATION = "coder.isning.moe/edgeone-certificate-order-created-at"
ORDER_LIFETIME = timedelta(hours=48)


def log(message: str) -> None:
    print(message, flush=True)


def required_env(name: str) -> str:
    value = os.getenv(name, "").strip()
    if not value:
        raise RuntimeError(f"required environment variable {name} is empty")
    return value


def kubernetes_request(path: str, method: str = "GET", body: dict[str, Any] | None = None) -> dict[str, Any]:
    with open(TOKEN_PATH, encoding="utf-8") as token_file:
        token = token_file.read().strip()
    data = None if body is None else json.dumps(body, separators=(",", ":")).encode()
    request = urllib.request.Request(
        f"{KUBERNETES_API}{path}",
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/json",
            "Content-Type": "application/merge-patch+json" if method == "PATCH" else "application/json",
        },
    )
    context = ssl.create_default_context(cafile=CA_PATH)
    with urllib.request.urlopen(request, context=context, timeout=30) as response:
        return json.load(response)


def terraform_ready(name: str) -> bool:
    path = f"/apis/infra.contrib.fluxcd.io/v1alpha2/namespaces/{NAMESPACE}/terraforms/{name}"
    resource = kubernetes_request(path)
    return any(
        condition.get("type") == "Ready" and condition.get("status") == "True"
        for condition in resource.get("status", {}).get("conditions", [])
    )


def wait_for_terraform(names: list[str], timeout_seconds: int = 900) -> None:
    deadline = time.monotonic() + timeout_seconds
    pending = set(names)
    while pending:
        for name in list(pending):
            try:
                if terraform_ready(name):
                    pending.remove(name)
                    log(f"Terraform dependency {name} is ready")
            except (urllib.error.URLError, urllib.error.HTTPError) as error:
                log(f"Waiting for Terraform dependency {name}: {error}")
        if not pending:
            return
        if time.monotonic() >= deadline:
            raise TimeoutError(f"Terraform dependencies not ready: {', '.join(sorted(pending))}")
        time.sleep(15)


def dns_endpoint_path(name: str | None = None) -> str:
    base = f"/apis/externaldns.k8s.io/v1alpha1/namespaces/{NAMESPACE}/dnsendpoints"
    return base if name is None else f"{base}/{name}"


def get_dns_endpoint(name: str) -> dict[str, Any] | None:
    try:
        return kubernetes_request(dns_endpoint_path(name))
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise


def normalize_challenge_name(subdomain: str) -> str:
    zone = "isning.moe"
    expected_name = f"_acme-challenge.coder.{zone}"
    normalized_name = subdomain.rstrip(".").lower()
    if not normalized_name.endswith(f".{zone}"):
        normalized_name = f"{normalized_name}.{zone}"
    if normalized_name != expected_name:
        raise RuntimeError(f"EdgeOne returned unsafe challenge name {subdomain!r}")
    return normalized_name


def validate_challenge(subdomain: str, record_type: str, record_value: str) -> str:
    normalized_name = normalize_challenge_name(subdomain)
    if record_type.upper() != "CNAME":
        raise RuntimeError(f"EdgeOne returned unsupported challenge record type {record_type!r}")
    if not record_value.strip():
        raise RuntimeError("EdgeOne returned an empty challenge target")
    return normalized_name


def reconcile_dns_endpoint(
    name: str,
    subdomain: str,
    record_type: str,
    record_value: str,
    order_created_at: datetime | None = None,
) -> None:
    dns_name = validate_challenge(subdomain, record_type, record_value)
    created_at = order_created_at or datetime.now(timezone.utc)
    endpoint = {
        "apiVersion": "externaldns.k8s.io/v1alpha1",
        "kind": "DNSEndpoint",
        "metadata": {
            "name": name,
            "namespace": NAMESPACE,
            "labels": {
                "app.kubernetes.io/managed-by": "coder-edgeone-certificate",
                "app.kubernetes.io/part-of": "coder",
            },
            "annotations": {
                ORDER_CREATED_AT_ANNOTATION: created_at.isoformat().replace("+00:00", "Z"),
            },
        },
        "spec": {
            "endpoints": [
                {
                    "dnsName": dns_name,
                    "recordType": record_type.upper(),
                    "recordTTL": 60,
                    "targets": [record_value],
                    "providerSpecific": [
                        {
                            "name": "external-dns.alpha.kubernetes.io/cloudflare-proxied",
                            "value": "false",
                        }
                    ],
                }
            ]
        },
    }
    if get_dns_endpoint(name) is None:
        kubernetes_request(dns_endpoint_path(), "POST", endpoint)
        log(f"Created DNS delegation endpoint {name}")
    else:
        kubernetes_request(dns_endpoint_path(name), "PATCH", endpoint)
        log(f"Updated DNS delegation endpoint {name}")


def edgeone_client():
    from tencentcloud.common import credential
    from tencentcloud.common.profile.client_profile import ClientProfile
    from tencentcloud.teo.v20220901 import teo_client

    credentials = credential.Credential(
        required_env("TENCENTCLOUD_SECRET_ID"),
        required_env("TENCENTCLOUD_SECRET_KEY"),
    )
    profile = ClientProfile()
    profile.httpProfile.endpoint = "teo.tencentcloudapi.com"
    return teo_client.TeoClient(credentials, "", profile)


def check_certificate(client: Any, zone_id: str, domain: str) -> Any:
    from tencentcloud.teo.v20220901 import models

    request = models.CheckFreeCertificateVerificationRequest()
    request.ZoneId = zone_id
    request.Domain = domain
    return client.CheckFreeCertificateVerification(request)


def apply_certificate(client: Any, zone_id: str, domain: str) -> Any:
    from tencentcloud.teo.v20220901 import models

    request = models.ApplyFreeCertificateRequest()
    request.ZoneId = zone_id
    request.Domain = domain
    request.VerificationMethod = "dns_challenge"
    return client.ApplyFreeCertificate(request)


def deploy_certificate(client: Any, zone_id: str, domain: str) -> None:
    from tencentcloud.teo.v20220901 import models

    request = models.ModifyHostsCertificateRequest()
    request.ZoneId = zone_id
    request.Hosts = [domain]
    request.Mode = "eofreecert_manual"
    client.ModifyHostsCertificate(request)
    log(f"Submitted verified free certificate deployment for {domain}")


def certificate_is_verified(client: Any, zone_id: str, domain: str) -> bool:
    try:
        response = check_certificate(client, zone_id, domain)
    except Exception as error:  # Tencent SDK exposes pending states as API errors.
        if permanent_tencent_error(error):
            raise
        log(f"Certificate verification is pending: {error}")
        return False
    return certificate_response_is_verified(response, domain)


def certificate_response_is_verified(response: Any, domain: str) -> bool:
    common_name = getattr(response, "CommonName", None)
    expires_at = getattr(response, "ExpireTime", None)
    return common_name == domain and isinstance(expires_at, str) and bool(expires_at.strip())


def order_is_fresh(endpoint: dict[str, Any], now: datetime | None = None) -> bool:
    timestamp = endpoint.get("metadata", {}).get("annotations", {}).get(ORDER_CREATED_AT_ANNOTATION)
    if not isinstance(timestamp, str):
        return False
    try:
        created_at = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    except ValueError:
        return False
    if created_at.tzinfo is None:
        return False
    current_time = now or datetime.now(timezone.utc)
    age = current_time - created_at.astimezone(timezone.utc)
    return timedelta(0) <= age < ORDER_LIFETIME


def permanent_tencent_error(error: Exception) -> bool:
    try:
        from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
    except ImportError:
        return False
    if not isinstance(error, TencentCloudSDKException):
        return False
    code = error.get_code() or ""
    return code.startswith(("AuthFailure", "UnauthorizedOperation", "UnsupportedOperation"))


def wait_for_verification(client: Any, zone_id: str, domain: str, timeout_seconds: int = 2700) -> None:
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        if certificate_is_verified(client, zone_id, domain):
            return
        time.sleep(30)
    raise TimeoutError("EdgeOne did not validate the DNS challenge within 45 minutes")


def main() -> int:
    zone_id = required_env("EDGEONE_ZONE_ID")
    domain = required_env("EDGEONE_DOMAIN")
    endpoint_name = required_env("CHALLENGE_DNS_ENDPOINT")
    dependencies = [required_env("CONTROL_TERRAFORM"), required_env("SYNC_TERRAFORM")]

    wait_for_terraform(dependencies)
    client = edgeone_client()

    # A persistent delegation means EdgeOne can renew without changing Cloudflare.
    # If it already exists and the certificate is valid, avoid starting a new order.
    endpoint = get_dns_endpoint(endpoint_name)
    if endpoint is not None:
        if certificate_is_verified(client, zone_id, domain):
            deploy_certificate(client, zone_id, domain)
            return 0
        if order_is_fresh(endpoint):
            log("Resuming the existing EdgeOne certificate order")
            wait_for_verification(client, zone_id, domain)
            deploy_certificate(client, zone_id, domain)
            return 0

    response = apply_certificate(client, zone_id, domain)
    verification = getattr(response, "DnsVerification", None)
    if verification is None:
        raise RuntimeError("EdgeOne did not return DNS verification data")
    reconcile_dns_endpoint(
        endpoint_name,
        required_value(verification, "Subdomain"),
        required_value(verification, "RecordType"),
        required_value(verification, "RecordValue"),
    )

    wait_for_verification(client, zone_id, domain)
    deploy_certificate(client, zone_id, domain)
    return 0


def required_value(value: Any, attribute: str) -> str:
    result = getattr(value, attribute, None)
    if not isinstance(result, str) or not result.strip():
        raise RuntimeError(f"EdgeOne response field {attribute} is empty")
    return result.strip()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        log(f"Certificate reconciliation failed: {error}")
        sys.exit(1)
