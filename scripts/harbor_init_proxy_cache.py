#!/usr/bin/env python3
"""Initialize Harbor proxy cache registries and projects.

Usage:
  HARBOR_PASSWORD=... python3 scripts/harbor_init_proxy_cache.py \
    --harbor-url https://harbor.isning.moe \
    --username admin \
    --config scripts/harbor_proxy_cache_config.example.json
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any


def _request_json(
    method: str,
    url: str,
    username: str,
    password: str,
    payload: dict[str, Any] | None = None,
    accepted_codes: tuple[int, ...] = (200,),
) -> Any:
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")

    req = urllib.request.Request(url=url, method=method, data=data)
    req.add_header("Accept", "application/json")
    req.add_header("Content-Type", "application/json")

    # Basic auth header
    credentials = f"{username}:{password}".encode("utf-8")
    import base64

    req.add_header("Authorization", "Basic " + base64.b64encode(credentials).decode("ascii"))

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            if resp.status not in accepted_codes:
                raise RuntimeError(f"Unexpected status {resp.status} for {method} {url}")
            body = resp.read().decode("utf-8")
            return json.loads(body) if body else None
    except urllib.error.HTTPError as exc:
        if exc.code in accepted_codes:
            body = exc.read().decode("utf-8") if exc.fp else ""
            return json.loads(body) if body else None
        detail = exc.read().decode("utf-8") if exc.fp else ""
        raise RuntimeError(f"HTTP {exc.code} on {method} {url}: {detail}") from exc


def _list_registries(base_url: str, username: str, password: str) -> list[dict[str, Any]]:
    url = f"{base_url}/api/v2.0/registries?page=1&page_size=200"
    return _request_json("GET", url, username, password, accepted_codes=(200,))


def _list_projects(base_url: str, username: str, password: str) -> list[dict[str, Any]]:
    url = f"{base_url}/api/v2.0/projects?page=1&page_size=500&with_detail=true"
    return _request_json("GET", url, username, password, accepted_codes=(200,))


def _find_registry_id(registries: list[dict[str, Any]], name: str) -> int | None:
    for item in registries:
        if item.get("name") == name:
            return int(item["id"])
    return None


def _find_project(projects: list[dict[str, Any]], name: str) -> dict[str, Any] | None:
    for item in projects:
        if item.get("name") == name:
            return item
    return None


def _create_registry(
    base_url: str,
    username: str,
    password: str,
    item: dict[str, Any],
) -> None:
    url = f"{base_url}/api/v2.0/registries"
    payload: dict[str, Any] = {
        "name": item["name"],
        "type": item["provider"],
        "url": item["endpoint"],
        "insecure": bool(item.get("insecure", False)),
    }

    credential: dict[str, str] = {"type": item.get("credential_type", "basic")}
    access_key_env = item.get("access_key_env")
    access_secret_env = item.get("access_secret_env")
    if access_key_env and access_secret_env:
        access_key = os.getenv(access_key_env, "")
        access_secret = os.getenv(access_secret_env, "")
        if access_key and access_secret:
            credential["access_key"] = access_key
            credential["access_secret"] = access_secret

    if len(credential) > 1:
        payload["credential"] = credential

    _request_json("POST", url, username, password, payload=payload, accepted_codes=(201, 409))


def _create_project(
    base_url: str,
    username: str,
    password: str,
    item: dict[str, Any],
    registry_id: int,
) -> None:
    url = f"{base_url}/api/v2.0/projects"
    is_public = bool(item.get("public", True))
    payload = {
        "project_name": item["name"],
        "registry_id": registry_id,
        "metadata": {"public": "true" if is_public else "false"},
        "storage_limit": int(item.get("storage_limit", -1)),
    }
    _request_json("POST", url, username, password, payload=payload, accepted_codes=(201, 409))


def main() -> int:
    parser = argparse.ArgumentParser(description="Initialize Harbor proxy cache projects")
    parser.add_argument("--harbor-url", required=True, help="Harbor base URL, e.g. https://harbor.example.com")
    parser.add_argument("--username", default="admin", help="Harbor username")
    parser.add_argument(
        "--password",
        default=os.getenv("HARBOR_PASSWORD", ""),
        help="Harbor password (or set HARBOR_PASSWORD)",
    )
    parser.add_argument("--config", required=True, help="Path to JSON config file")
    args = parser.parse_args()

    if not args.password:
        print("Error: missing Harbor password. Set --password or HARBOR_PASSWORD.", file=sys.stderr)
        return 2

    with open(args.config, "r", encoding="utf-8") as f:
        config = json.load(f)

    base_url = args.harbor_url.rstrip("/")

    registry_items = config.get("registries", [])
    project_items = config.get("projects", [])

    if not registry_items:
        print("No registries configured, nothing to do.")
        return 0

    # Step 1: create or reuse upstream registries
    for item in registry_items:
        name = item["name"]
        registries = _list_registries(base_url, args.username, args.password)
        registry_id = _find_registry_id(registries, name)
        if registry_id is None:
            print(f"Creating registry: {name}")
            _create_registry(base_url, args.username, args.password, item)
        else:
            print(f"Registry already exists: {name} (id={registry_id})")

    # Step 2: create proxy cache projects bound to registry ids
    registries = _list_registries(base_url, args.username, args.password)
    projects = _list_projects(base_url, args.username, args.password)

    for item in project_items:
        name = item["name"]
        registry_name = item["registry"]
        registry_id = _find_registry_id(registries, registry_name)
        if registry_id is None:
            raise RuntimeError(
                f"Registry '{registry_name}' not found for project '{name}'. "
                "Check config.registries entries."
            )

        if _find_project(projects, name) is not None:
            print(f"Project already exists: {name}")
            continue

        print(f"Creating proxy cache project: {name} -> registry '{registry_name}' (id={registry_id})")
        _create_project(base_url, args.username, args.password, item, registry_id)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
